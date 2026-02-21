#!/usr/bin/env python3
"""
One-time script to convert existing Swift territory data into territories.json.

Parses:
  - TerritoryPolygonData.swift  (polygon boundaries)
  - TerritoryData.swift         (territory definitions + adjacency graph)

Produces:
  - ios/Diplomacy/Resources/territories.json
"""

import json
import os
import re
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(SCRIPT_DIR)
POLYGON_FILE = os.path.join(ROOT, "ios", "Diplomacy", "Models", "TerritoryPolygonData.swift")
DATA_FILE = os.path.join(ROOT, "ios", "Diplomacy", "Models", "TerritoryData.swift")
OUTPUT_DIR = os.path.join(ROOT, "ios", "Diplomacy", "Resources")
OUTPUT_FILE = os.path.join(OUTPUT_DIR, "territories.json")


def parse_polygons(filepath):
    """Parse TerritoryPolygonData.swift to extract polygon boundaries."""
    with open(filepath, "r") as f:
        content = f.read()

    polygons = {}
    # Match each territory entry: "ID": [ CGPoint(...), ... ]
    # The pattern captures territory ID and then all CGPoint values
    pattern = r'"(\w+)":\s*\[([\s\S]*?)\],'
    for match in re.finditer(pattern, content):
        tid = match.group(1)
        points_str = match.group(2)
        points = []
        for pt in re.finditer(r'CGPoint\(x:\s*([\d.]+),\s*y:\s*([\d.]+)\)', points_str):
            points.append([round(float(pt.group(1)), 4), round(float(pt.group(2)), 4)])
        if points:
            polygons[tid] = points
    return polygons


def parse_territories(filepath):
    """Parse TerritoryData.swift to extract territory definitions and adjacencies."""
    with open(filepath, "r") as f:
        content = f.read()

    territories = []
    # Match Territory(...) constructors
    pattern = (
        r'Territory\(id:\s*"(\w+)",\s*name:\s*"([^"]+)",\s*type:\s*\.(\w+),\s*'
        r'isSupplyCenter:\s*(true|false),\s*homeCenter:\s*(\.\w+|nil),\s*'
        r'center:\s*CGPoint\(x:\s*([\d.]+),\s*y:\s*([\d.]+)\),\s*'
        r'parentTerritory:\s*("(\w+)"|nil)'
    )
    for match in re.finditer(pattern, content):
        tid = match.group(1)
        name = match.group(2)
        ttype = match.group(3)
        is_sc = match.group(4) == "true"
        home = match.group(5)
        cx = float(match.group(6))
        cy = float(match.group(7))
        parent = match.group(9)  # group 9 is the inner capture without quotes

        if home == "nil":
            home = None
        else:
            home = home.lstrip(".")

        territories.append({
            "id": tid,
            "name": name,
            "type": ttype,
            "isSupplyCenter": is_sc,
            "homeCountry": home,
            "center": [round(cx, 4), round(cy, 4)],
            "parentTerritory": parent,
        })

    # Parse adjacency edges
    edges = []
    edge_pattern = r'\("(\w+)",\s*"(\w+)"\)'
    # Find the edges array section — match from "= [" to the final "]"
    edges_section = re.search(r'let edges:.*?=\s*\[([\s\S]*?)\n\s*\]', content)
    if edges_section:
        for edge_match in re.finditer(edge_pattern, edges_section.group(1)):
            edges.append((edge_match.group(1), edge_match.group(2)))

    return territories, edges


def build_adjacency_graph(territories, edges):
    """Build bidirectional adjacency graph from edges."""
    graph = {t["id"]: set() for t in territories}
    for a, b in edges:
        if a not in graph:
            graph[a] = set()
        if b not in graph:
            graph[b] = set()
        graph[a].add(b)
        graph[b].add(a)
    return graph


def main():
    print("Parsing polygon data...")
    polygons = parse_polygons(POLYGON_FILE)
    print(f"  Found {len(polygons)} polygon boundaries")

    print("Parsing territory definitions...")
    territories, edges = parse_territories(DATA_FILE)
    print(f"  Found {len(territories)} territory definitions")
    print(f"  Found {len(edges)} adjacency edges")

    adjacency_graph = build_adjacency_graph(territories, edges)

    # Identify coast variants
    coast_variants = {}  # parent_id -> [variant entries]
    parent_ids = set()
    for t in territories:
        if t["parentTerritory"]:
            parent = t["parentTerritory"]
            parent_ids.add(parent)
            if parent not in coast_variants:
                coast_variants[parent] = []
            # Convert ID format: BUL_EC -> BUL/EC
            display_id = t["id"].replace("_", "/")
            coast_variants[parent].append({
                "id": display_id,
                "name": t["name"],
                "adjacencies": sorted(adjacency_graph.get(t["id"], set()))
            })

    # Build output territories (excluding coast variant entries)
    output_territories = []
    for t in territories:
        if t["parentTerritory"]:
            continue  # Skip coast variants; they become coasts[] on parent

        tid = t["id"]
        polygon = polygons.get(tid)

        # Determine disambiguation priority: sea zones get 10, land/coast get 0
        disambig = 10 if t["type"] == "sea" else 0

        entry = {
            "id": tid,
            "name": t["name"],
            "type": t["type"],
            "isSupplyCenter": t["isSupplyCenter"],
        }

        if t["homeCountry"]:
            entry["homeCountry"] = t["homeCountry"]

        entry["labelAnchor"] = t["center"]
        entry["unitAnchor"] = t["center"]

        if polygon:
            entry["polygon"] = polygon

        # Get adjacencies for this territory (excluding coast variant IDs from the list)
        adj = sorted(adjacency_graph.get(tid, set()))
        entry["adjacencies"] = adj

        if tid in coast_variants:
            entry["coasts"] = coast_variants[tid]

        entry["disambiguationPriority"] = disambig

        output_territories.append(entry)

    # Build final JSON
    output = {
        "version": "1.0.0",
        "mapAspectRatio": 1.3493,
        "territories": output_territories
    }

    # Validation
    top_level_count = len(output_territories)
    coast_variant_count = sum(len(v) for v in coast_variants.values())
    sc_count = sum(1 for t in output_territories if t["isSupplyCenter"])
    home_count = sum(1 for t in output_territories if t.get("homeCountry"))
    poly_count = sum(1 for t in output_territories if "polygon" in t)

    print(f"\nValidation:")
    print(f"  Top-level territories: {top_level_count} (expected 75)")
    print(f"  Coast variants: {coast_variant_count} (expected 6)")
    print(f"  Total: {top_level_count + coast_variant_count} (expected 81)")
    print(f"  Supply centers: {sc_count} (expected 34)")
    print(f"  Home centers: {home_count} (expected 22)")
    print(f"  Territories with polygons: {poly_count}")

    # Validate polygon coordinates in [0, 1]
    bad_coords = 0
    for t in output_territories:
        if "polygon" in t:
            for pt in t["polygon"]:
                if not (0 <= pt[0] <= 1 and 0 <= pt[1] <= 1):
                    bad_coords += 1
            if len(t["polygon"]) < 3:
                print(f"  WARNING: {t['id']} has fewer than 3 polygon vertices")
    if bad_coords:
        print(f"  WARNING: {bad_coords} coordinates outside [0, 1]")
    else:
        print(f"  All polygon coordinates in [0, 1] range")

    # Validate all adjacency IDs resolve
    all_ids = {t["id"] for t in territories}
    unresolved = set()
    for t in output_territories:
        for adj_id in t["adjacencies"]:
            if adj_id not in all_ids:
                unresolved.add(adj_id)
        if "coasts" in t:
            for coast in t["coasts"]:
                for adj_id in coast["adjacencies"]:
                    if adj_id not in all_ids:
                        unresolved.add(adj_id)
    if unresolved:
        print(f"  WARNING: Unresolved adjacency IDs: {unresolved}")
    else:
        print(f"  All adjacency IDs resolve")

    # Write output
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    with open(OUTPUT_FILE, "w") as f:
        json.dump(output, f, indent=2)
    print(f"\nWrote {OUTPUT_FILE}")


if __name__ == "__main__":
    main()
