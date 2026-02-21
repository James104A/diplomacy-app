import Foundation

// MARK: - Territory Polygon Boundaries
// High-fidelity polygons derived from the standard Diplomacy SVG map.
// Normalized coordinates (viewBox 0 0 1835 1360 → 0-1 range).
// Coast variants (BUL_EC, BUL_SC, SPA_NC, SPA_SC, STP_NC, STP_SC) use the parent polygon.
// 75 territories total.

enum TerritoryPolygonData {

    static let boundaries: [String: [CGPoint]] = [
    "ADR": [
        CGPoint(x: 0.4953, y: 0.8566), CGPoint(x: 0.4975, y: 0.8338), CGPoint(x: 0.4981, y: 0.8221),
        CGPoint(x: 0.4763, y: 0.7971), CGPoint(x: 0.4605, y: 0.7801), CGPoint(x: 0.4506, y: 0.7713),
        CGPoint(x: 0.4332, y: 0.7515), CGPoint(x: 0.4288, y: 0.7368), CGPoint(x: 0.4305, y: 0.7243),
        CGPoint(x: 0.4218, y: 0.7368), CGPoint(x: 0.418, y: 0.7294), CGPoint(x: 0.4147, y: 0.7162),
        CGPoint(x: 0.4054, y: 0.7206), CGPoint(x: 0.4027, y: 0.7243), CGPoint(x: 0.4011, y: 0.736),
        CGPoint(x: 0.4011, y: 0.7471), CGPoint(x: 0.4169, y: 0.7713), CGPoint(x: 0.4207, y: 0.7882),
        CGPoint(x: 0.431, y: 0.8066), CGPoint(x: 0.4485, y: 0.8154), CGPoint(x: 0.4506, y: 0.8257),
        CGPoint(x: 0.4768, y: 0.8507), CGPoint(x: 0.4844, y: 0.8603), CGPoint(x: 0.4953, y: 0.8566)
    ],
    "AEG": [
        CGPoint(x: 0.5624, y: 0.8463), CGPoint(x: 0.5613, y: 0.8551), CGPoint(x: 0.5591, y: 0.8654),
        CGPoint(x: 0.5482, y: 0.8507), CGPoint(x: 0.5498, y: 0.8824), CGPoint(x: 0.5487, y: 0.889),
        CGPoint(x: 0.5531, y: 0.8956), CGPoint(x: 0.5591, y: 0.8934), CGPoint(x: 0.5656, y: 0.914),
        CGPoint(x: 0.558, y: 0.9176), CGPoint(x: 0.5477, y: 0.9294), CGPoint(x: 0.5542, y: 0.9559),
        CGPoint(x: 0.5705, y: 0.975), CGPoint(x: 0.5907, y: 0.9765), CGPoint(x: 0.6032, y: 0.9794),
        CGPoint(x: 0.6294, y: 0.9441), CGPoint(x: 0.6212, y: 0.9353), CGPoint(x: 0.6158, y: 0.9265),
        CGPoint(x: 0.6049, y: 0.9037), CGPoint(x: 0.6081, y: 0.8868), CGPoint(x: 0.6038, y: 0.8699),
        CGPoint(x: 0.5912, y: 0.8574), CGPoint(x: 0.5956, y: 0.8456), CGPoint(x: 0.5684, y: 0.8426),
        CGPoint(x: 0.5624, y: 0.8463)
    ],
    "ALB": [
        CGPoint(x: 0.5199, y: 0.8426), CGPoint(x: 0.5128, y: 0.8287), CGPoint(x: 0.5068, y: 0.8029),
        CGPoint(x: 0.503, y: 0.8), CGPoint(x: 0.4937, y: 0.811), CGPoint(x: 0.4997, y: 0.8235),
        CGPoint(x: 0.497, y: 0.85), CGPoint(x: 0.4975, y: 0.8581), CGPoint(x: 0.5068, y: 0.8699),
        CGPoint(x: 0.5111, y: 0.8632), CGPoint(x: 0.5177, y: 0.8574), CGPoint(x: 0.5199, y: 0.8426)
    ],
    "ANK": [
        CGPoint(x: 0.6697, y: 0.8779), CGPoint(x: 0.6888, y: 0.8647), CGPoint(x: 0.6975, y: 0.8574),
        CGPoint(x: 0.7106, y: 0.8603), CGPoint(x: 0.7264, y: 0.8574), CGPoint(x: 0.752, y: 0.8287),
        CGPoint(x: 0.7716, y: 0.8257), CGPoint(x: 0.7787, y: 0.825), CGPoint(x: 0.7858, y: 0.7875),
        CGPoint(x: 0.7564, y: 0.7963), CGPoint(x: 0.7406, y: 0.7912), CGPoint(x: 0.7389, y: 0.7926),
        CGPoint(x: 0.7318, y: 0.7868), CGPoint(x: 0.7253, y: 0.7912), CGPoint(x: 0.7171, y: 0.7831),
        CGPoint(x: 0.7095, y: 0.7875), CGPoint(x: 0.6877, y: 0.7934), CGPoint(x: 0.6757, y: 0.8059),
        CGPoint(x: 0.6675, y: 0.8191), CGPoint(x: 0.667, y: 0.825), CGPoint(x: 0.6703, y: 0.8397),
        CGPoint(x: 0.6735, y: 0.8551), CGPoint(x: 0.6697, y: 0.8779)
    ],
    "APU": [
        CGPoint(x: 0.4234, y: 0.7985), CGPoint(x: 0.4169, y: 0.8103), CGPoint(x: 0.4218, y: 0.8184),
        CGPoint(x: 0.4338, y: 0.8309), CGPoint(x: 0.443, y: 0.8456), CGPoint(x: 0.4457, y: 0.8559),
        CGPoint(x: 0.4561, y: 0.864), CGPoint(x: 0.461, y: 0.8544), CGPoint(x: 0.4637, y: 0.8529),
        CGPoint(x: 0.467, y: 0.8566), CGPoint(x: 0.4763, y: 0.8647), CGPoint(x: 0.4817, y: 0.8662),
        CGPoint(x: 0.4806, y: 0.8574), CGPoint(x: 0.4686, y: 0.8449), CGPoint(x: 0.4501, y: 0.8265),
        CGPoint(x: 0.4479, y: 0.8213), CGPoint(x: 0.4474, y: 0.8162), CGPoint(x: 0.443, y: 0.8154),
        CGPoint(x: 0.4359, y: 0.8125), CGPoint(x: 0.4234, y: 0.7985)
    ],
    "ARM": [
        CGPoint(x: 0.8043, y: 0.7706), CGPoint(x: 0.7863, y: 0.7868), CGPoint(x: 0.788, y: 0.7875),
        CGPoint(x: 0.7869, y: 0.8331), CGPoint(x: 0.794, y: 0.8441), CGPoint(x: 0.7967, y: 0.8581),
        CGPoint(x: 0.8245, y: 0.8581), CGPoint(x: 0.831, y: 0.8588), CGPoint(x: 0.8365, y: 0.8588),
        CGPoint(x: 0.8883, y: 0.8662), CGPoint(x: 0.8991, y: 0.8669), CGPoint(x: 0.915, y: 0.864),
        CGPoint(x: 0.9438, y: 0.836), CGPoint(x: 0.9596, y: 0.8162), CGPoint(x: 0.9498, y: 0.814),
        CGPoint(x: 0.9226, y: 0.7956), CGPoint(x: 0.9122, y: 0.7882), CGPoint(x: 0.9062, y: 0.7728),
        CGPoint(x: 0.8981, y: 0.7838), CGPoint(x: 0.8774, y: 0.8022), CGPoint(x: 0.8566, y: 0.7956),
        CGPoint(x: 0.849, y: 0.7956), CGPoint(x: 0.8272, y: 0.7941), CGPoint(x: 0.8043, y: 0.7706)
    ],
    "BAL": [
        CGPoint(x: 0.4714, y: 0.3993), CGPoint(x: 0.4697, y: 0.4147), CGPoint(x: 0.461, y: 0.4478),
        CGPoint(x: 0.4528, y: 0.4485), CGPoint(x: 0.4348, y: 0.4662), CGPoint(x: 0.4294, y: 0.4662),
        CGPoint(x: 0.4239, y: 0.4757), CGPoint(x: 0.3934, y: 0.4662), CGPoint(x: 0.3972, y: 0.4801),
        CGPoint(x: 0.4005, y: 0.4971), CGPoint(x: 0.4071, y: 0.4963), CGPoint(x: 0.4207, y: 0.4897),
        CGPoint(x: 0.4299, y: 0.486), CGPoint(x: 0.4316, y: 0.486), CGPoint(x: 0.4425, y: 0.5),
        CGPoint(x: 0.4692, y: 0.4897), CGPoint(x: 0.497, y: 0.4926), CGPoint(x: 0.5046, y: 0.4853),
        CGPoint(x: 0.5111, y: 0.475), CGPoint(x: 0.5144, y: 0.475), CGPoint(x: 0.5171, y: 0.464),
        CGPoint(x: 0.5215, y: 0.4154), CGPoint(x: 0.5095, y: 0.4147), CGPoint(x: 0.4714, y: 0.3993)
    ],
    "BAR": [
        CGPoint(x: 0.5357, y: 0.0037), CGPoint(x: 0.5351, y: 0.0669), CGPoint(x: 0.5471, y: 0.0676),
        CGPoint(x: 0.5575, y: 0.0676), CGPoint(x: 0.564, y: 0.0875), CGPoint(x: 0.588, y: 0.0963),
        CGPoint(x: 0.6261, y: 0.1059), CGPoint(x: 0.6528, y: 0.1596), CGPoint(x: 0.6092, y: 0.1603),
        CGPoint(x: 0.6103, y: 0.1735), CGPoint(x: 0.6294, y: 0.2147), CGPoint(x: 0.6534, y: 0.2206),
        CGPoint(x: 0.6408, y: 0.1912), CGPoint(x: 0.6823, y: 0.1993), CGPoint(x: 0.6637, y: 0.1853),
        CGPoint(x: 0.6828, y: 0.1449), CGPoint(x: 0.6654, y: 0.086), CGPoint(x: 0.6986, y: 0.1169),
        CGPoint(x: 0.722, y: 0.0618), CGPoint(x: 0.7286, y: 0.0735), CGPoint(x: 0.7351, y: 0.0596),
        CGPoint(x: 0.7531, y: 0.025), CGPoint(x: 0.764, y: 0.0294), CGPoint(x: 0.7558, y: 0.0044),
        CGPoint(x: 0.5357, y: 0.0037)
    ],
    "BEL": [
        CGPoint(x: 0.2833, y: 0.5596), CGPoint(x: 0.3008, y: 0.5735), CGPoint(x: 0.3171, y: 0.5875),
        CGPoint(x: 0.3318, y: 0.5956), CGPoint(x: 0.3335, y: 0.5868), CGPoint(x: 0.3275, y: 0.5662),
        CGPoint(x: 0.3259, y: 0.5559), CGPoint(x: 0.3199, y: 0.5522), CGPoint(x: 0.316, y: 0.55),
        CGPoint(x: 0.3084, y: 0.5426), CGPoint(x: 0.2959, y: 0.5463), CGPoint(x: 0.2872, y: 0.5493),
        CGPoint(x: 0.2833, y: 0.5596)
    ],
    "BER": [
        CGPoint(x: 0.4054, y: 0.5647), CGPoint(x: 0.4218, y: 0.5581), CGPoint(x: 0.4392, y: 0.5537),
        CGPoint(x: 0.4479, y: 0.5463), CGPoint(x: 0.4474, y: 0.536), CGPoint(x: 0.4441, y: 0.525),
        CGPoint(x: 0.4425, y: 0.5022), CGPoint(x: 0.4332, y: 0.4978), CGPoint(x: 0.431, y: 0.4926),
        CGPoint(x: 0.4327, y: 0.4897), CGPoint(x: 0.4305, y: 0.4875), CGPoint(x: 0.4163, y: 0.4934),
        CGPoint(x: 0.4098, y: 0.4963), CGPoint(x: 0.4076, y: 0.5132), CGPoint(x: 0.4038, y: 0.5456),
        CGPoint(x: 0.4054, y: 0.5647)
    ],
    "BLA": [
        CGPoint(x: 0.7493, y: 0.6338), CGPoint(x: 0.7019, y: 0.6743), CGPoint(x: 0.709, y: 0.6971),
        CGPoint(x: 0.7128, y: 0.7059), CGPoint(x: 0.6975, y: 0.7235), CGPoint(x: 0.685, y: 0.711),
        CGPoint(x: 0.6795, y: 0.6926), CGPoint(x: 0.6659, y: 0.6875), CGPoint(x: 0.6626, y: 0.6728),
        CGPoint(x: 0.6381, y: 0.6853), CGPoint(x: 0.6354, y: 0.7118), CGPoint(x: 0.6234, y: 0.7647),
        CGPoint(x: 0.6141, y: 0.7912), CGPoint(x: 0.6321, y: 0.8125), CGPoint(x: 0.667, y: 0.8162),
        CGPoint(x: 0.7117, y: 0.7846), CGPoint(x: 0.7291, y: 0.7875), CGPoint(x: 0.74, y: 0.7882),
        CGPoint(x: 0.7776, y: 0.7882), CGPoint(x: 0.7983, y: 0.736), CGPoint(x: 0.7509, y: 0.7081),
        CGPoint(x: 0.7275, y: 0.6963), CGPoint(x: 0.7368, y: 0.6824), CGPoint(x: 0.7351, y: 0.6529),
        CGPoint(x: 0.7493, y: 0.6338)
    ],
    "BOH": [
        CGPoint(x: 0.4828, y: 0.6221), CGPoint(x: 0.4817, y: 0.6081), CGPoint(x: 0.4839, y: 0.6081),
        CGPoint(x: 0.4795, y: 0.6066), CGPoint(x: 0.473, y: 0.6029), CGPoint(x: 0.4637, y: 0.5985),
        CGPoint(x: 0.443, y: 0.5816), CGPoint(x: 0.4185, y: 0.5912), CGPoint(x: 0.4114, y: 0.5978),
        CGPoint(x: 0.413, y: 0.6081), CGPoint(x: 0.4261, y: 0.6301), CGPoint(x: 0.431, y: 0.6397),
        CGPoint(x: 0.4381, y: 0.6404), CGPoint(x: 0.4414, y: 0.6404), CGPoint(x: 0.4452, y: 0.6331),
        CGPoint(x: 0.4583, y: 0.6191), CGPoint(x: 0.4637, y: 0.6206), CGPoint(x: 0.4714, y: 0.6191),
        CGPoint(x: 0.4784, y: 0.6221), CGPoint(x: 0.4828, y: 0.6221)
    ],
    "BOT": [
        CGPoint(x: 0.4703, y: 0.3838), CGPoint(x: 0.4735, y: 0.3963), CGPoint(x: 0.509, y: 0.4118),
        CGPoint(x: 0.5248, y: 0.4096), CGPoint(x: 0.5433, y: 0.4228), CGPoint(x: 0.5487, y: 0.3919),
        CGPoint(x: 0.54, y: 0.3699), CGPoint(x: 0.5749, y: 0.3574), CGPoint(x: 0.5902, y: 0.3434),
        CGPoint(x: 0.6011, y: 0.3412), CGPoint(x: 0.5809, y: 0.3287), CGPoint(x: 0.552, y: 0.3426),
        CGPoint(x: 0.5313, y: 0.3419), CGPoint(x: 0.5226, y: 0.3368), CGPoint(x: 0.515, y: 0.3221),
        CGPoint(x: 0.5139, y: 0.2816), CGPoint(x: 0.5291, y: 0.2485), CGPoint(x: 0.546, y: 0.2162),
        CGPoint(x: 0.5253, y: 0.2007), CGPoint(x: 0.5166, y: 0.2382), CGPoint(x: 0.4948, y: 0.2684),
        CGPoint(x: 0.4817, y: 0.3007), CGPoint(x: 0.4877, y: 0.3375), CGPoint(x: 0.4904, y: 0.3669),
        CGPoint(x: 0.4703, y: 0.3838)
    ],
    "BRE": [
        CGPoint(x: 0.2376, y: 0.5632), CGPoint(x: 0.2387, y: 0.575), CGPoint(x: 0.2376, y: 0.5853),
        CGPoint(x: 0.2321, y: 0.589), CGPoint(x: 0.2212, y: 0.5831), CGPoint(x: 0.2163, y: 0.5779),
        CGPoint(x: 0.1983, y: 0.5794), CGPoint(x: 0.1962, y: 0.5846), CGPoint(x: 0.1934, y: 0.5904),
        CGPoint(x: 0.2027, y: 0.5971), CGPoint(x: 0.2158, y: 0.6118), CGPoint(x: 0.2201, y: 0.6243),
        CGPoint(x: 0.2201, y: 0.6331), CGPoint(x: 0.2261, y: 0.6485), CGPoint(x: 0.2485, y: 0.6566),
        CGPoint(x: 0.2512, y: 0.6294), CGPoint(x: 0.2512, y: 0.6169), CGPoint(x: 0.2506, y: 0.6096),
        CGPoint(x: 0.2545, y: 0.5794), CGPoint(x: 0.243, y: 0.5654), CGPoint(x: 0.2376, y: 0.5632),
        CGPoint(x: 0.1951, y: 0.5868), CGPoint(x: 0.1945, y: 0.5868), CGPoint(x: 0.1951, y: 0.5868)
    ],
    "BUD": [
        CGPoint(x: 0.5046, y: 0.6316), CGPoint(x: 0.5041, y: 0.636), CGPoint(x: 0.4981, y: 0.639),
        CGPoint(x: 0.485, y: 0.661), CGPoint(x: 0.4763, y: 0.6691), CGPoint(x: 0.4692, y: 0.6787),
        CGPoint(x: 0.4648, y: 0.6934), CGPoint(x: 0.473, y: 0.7125), CGPoint(x: 0.4817, y: 0.7191),
        CGPoint(x: 0.4948, y: 0.7375), CGPoint(x: 0.4991, y: 0.736), CGPoint(x: 0.5106, y: 0.7346),
        CGPoint(x: 0.5171, y: 0.7382), CGPoint(x: 0.5269, y: 0.739), CGPoint(x: 0.5427, y: 0.7301),
        CGPoint(x: 0.5509, y: 0.725), CGPoint(x: 0.5793, y: 0.7154), CGPoint(x: 0.5885, y: 0.7007),
        CGPoint(x: 0.5765, y: 0.6801), CGPoint(x: 0.5662, y: 0.6581), CGPoint(x: 0.5591, y: 0.6515),
        CGPoint(x: 0.546, y: 0.6346), CGPoint(x: 0.5226, y: 0.6257), CGPoint(x: 0.5046, y: 0.6316)
    ],
    "BUL": [
        CGPoint(x: 0.5411, y: 0.7566), CGPoint(x: 0.5406, y: 0.7691), CGPoint(x: 0.5455, y: 0.7846),
        CGPoint(x: 0.5422, y: 0.7978), CGPoint(x: 0.5417, y: 0.8243), CGPoint(x: 0.552, y: 0.8265),
        CGPoint(x: 0.5607, y: 0.8221), CGPoint(x: 0.5744, y: 0.8287), CGPoint(x: 0.5749, y: 0.836),
        CGPoint(x: 0.5749, y: 0.839), CGPoint(x: 0.5853, y: 0.839), CGPoint(x: 0.5907, y: 0.839),
        CGPoint(x: 0.5929, y: 0.8353), CGPoint(x: 0.5983, y: 0.8088), CGPoint(x: 0.6174, y: 0.8029),
        CGPoint(x: 0.613, y: 0.7926), CGPoint(x: 0.6141, y: 0.7853), CGPoint(x: 0.6163, y: 0.7706),
        CGPoint(x: 0.6229, y: 0.7618), CGPoint(x: 0.5934, y: 0.7603), CGPoint(x: 0.582, y: 0.7654),
        CGPoint(x: 0.5705, y: 0.7662), CGPoint(x: 0.5635, y: 0.7654), CGPoint(x: 0.5482, y: 0.7632),
        CGPoint(x: 0.5411, y: 0.7566)
    ],
    "BUR": [
        CGPoint(x: 0.315, y: 0.5919), CGPoint(x: 0.303, y: 0.6213), CGPoint(x: 0.2981, y: 0.6257),
        CGPoint(x: 0.2932, y: 0.6309), CGPoint(x: 0.2888, y: 0.6346), CGPoint(x: 0.2844, y: 0.6404),
        CGPoint(x: 0.279, y: 0.6441), CGPoint(x: 0.2757, y: 0.6574), CGPoint(x: 0.2659, y: 0.6735),
        CGPoint(x: 0.2686, y: 0.6809), CGPoint(x: 0.2763, y: 0.686), CGPoint(x: 0.2752, y: 0.6971),
        CGPoint(x: 0.2883, y: 0.7118), CGPoint(x: 0.2953, y: 0.6926), CGPoint(x: 0.297, y: 0.6824),
        CGPoint(x: 0.3019, y: 0.6824), CGPoint(x: 0.31, y: 0.6846), CGPoint(x: 0.3144, y: 0.6838),
        CGPoint(x: 0.3215, y: 0.6735), CGPoint(x: 0.3357, y: 0.6529), CGPoint(x: 0.3378, y: 0.6426),
        CGPoint(x: 0.3395, y: 0.6353), CGPoint(x: 0.334, y: 0.6206), CGPoint(x: 0.3308, y: 0.6),
        CGPoint(x: 0.315, y: 0.5919)
    ],
    "CLY": [
        CGPoint(x: 0.2338, y: 0.3757), CGPoint(x: 0.2376, y: 0.3809), CGPoint(x: 0.2523, y: 0.3853),
        CGPoint(x: 0.2539, y: 0.3676), CGPoint(x: 0.2583, y: 0.3434), CGPoint(x: 0.2675, y: 0.3309),
        CGPoint(x: 0.2599, y: 0.3294), CGPoint(x: 0.2539, y: 0.3368), CGPoint(x: 0.2452, y: 0.3449),
        CGPoint(x: 0.2376, y: 0.3449), CGPoint(x: 0.2403, y: 0.3588), CGPoint(x: 0.2338, y: 0.3757)
    ],
    "CON": [
        CGPoint(x: 0.619, y: 0.8066), CGPoint(x: 0.5972, y: 0.8346), CGPoint(x: 0.6038, y: 0.8434),
        CGPoint(x: 0.5967, y: 0.8544), CGPoint(x: 0.6005, y: 0.8485), CGPoint(x: 0.6223, y: 0.8294),
        CGPoint(x: 0.6239, y: 0.8176), CGPoint(x: 0.6643, y: 0.8191), CGPoint(x: 0.643, y: 0.825),
        CGPoint(x: 0.637, y: 0.8301), CGPoint(x: 0.6457, y: 0.8353), CGPoint(x: 0.6332, y: 0.8419),
        CGPoint(x: 0.618, y: 0.85), CGPoint(x: 0.5956, y: 0.8669), CGPoint(x: 0.606, y: 0.8743),
        CGPoint(x: 0.6125, y: 0.8713), CGPoint(x: 0.619, y: 0.875), CGPoint(x: 0.6392, y: 0.8757),
        CGPoint(x: 0.6566, y: 0.8757), CGPoint(x: 0.667, y: 0.8772), CGPoint(x: 0.6686, y: 0.8412),
        CGPoint(x: 0.6654, y: 0.8287), CGPoint(x: 0.6272, y: 0.8272), CGPoint(x: 0.6267, y: 0.8272),
        CGPoint(x: 0.6272, y: 0.8272)
    ],
    "DEN": [
        CGPoint(x: 0.4054, y: 0.4015), CGPoint(x: 0.3934, y: 0.4103), CGPoint(x: 0.3842, y: 0.4147),
        CGPoint(x: 0.3782, y: 0.4463), CGPoint(x: 0.3809, y: 0.4603), CGPoint(x: 0.3929, y: 0.4618),
        CGPoint(x: 0.3951, y: 0.4515), CGPoint(x: 0.4005, y: 0.4412), CGPoint(x: 0.4038, y: 0.4382),
        CGPoint(x: 0.4076, y: 0.436), CGPoint(x: 0.406, y: 0.4147), CGPoint(x: 0.4054, y: 0.4015),
        CGPoint(x: 0.4092, y: 0.4529), CGPoint(x: 0.4163, y: 0.4669), CGPoint(x: 0.4207, y: 0.4728),
        CGPoint(x: 0.4245, y: 0.461), CGPoint(x: 0.4234, y: 0.4544), CGPoint(x: 0.419, y: 0.4449),
        CGPoint(x: 0.4158, y: 0.4449), CGPoint(x: 0.4092, y: 0.4529), CGPoint(x: 0.4081, y: 0.4721),
        CGPoint(x: 0.4076, y: 0.475), CGPoint(x: 0.4109, y: 0.4735), CGPoint(x: 0.4081, y: 0.4721)
    ],
    "EAS": [
        CGPoint(x: 0.6043, y: 0.9824), CGPoint(x: 0.582, y: 0.9897), CGPoint(x: 0.5624, y: 0.9846),
        CGPoint(x: 0.5624, y: 0.9978), CGPoint(x: 0.7558, y: 0.989), CGPoint(x: 0.7526, y: 0.9493),
        CGPoint(x: 0.7498, y: 0.95), CGPoint(x: 0.7477, y: 0.9279), CGPoint(x: 0.7504, y: 0.911),
        CGPoint(x: 0.7297, y: 0.9213), CGPoint(x: 0.703, y: 0.9441), CGPoint(x: 0.6932, y: 0.939),
        CGPoint(x: 0.673, y: 0.9301), CGPoint(x: 0.6583, y: 0.9515), CGPoint(x: 0.6485, y: 0.9478),
        CGPoint(x: 0.6392, y: 0.9404), CGPoint(x: 0.6294, y: 0.9551), CGPoint(x: 0.6043, y: 0.9824),
        CGPoint(x: 0.7259, y: 0.9588), CGPoint(x: 0.7253, y: 0.9669), CGPoint(x: 0.7133, y: 0.9794),
        CGPoint(x: 0.6975, y: 0.9713), CGPoint(x: 0.7041, y: 0.9647), CGPoint(x: 0.7204, y: 0.9559),
        CGPoint(x: 0.7308, y: 0.9485)
    ],
    "EDI": [
        CGPoint(x: 0.2697, y: 0.3316), CGPoint(x: 0.2605, y: 0.3441), CGPoint(x: 0.2566, y: 0.3625),
        CGPoint(x: 0.2539, y: 0.389), CGPoint(x: 0.2545, y: 0.4066), CGPoint(x: 0.2626, y: 0.4235),
        CGPoint(x: 0.2708, y: 0.4243), CGPoint(x: 0.273, y: 0.414), CGPoint(x: 0.2681, y: 0.3904),
        CGPoint(x: 0.279, y: 0.3728), CGPoint(x: 0.2828, y: 0.364), CGPoint(x: 0.2697, y: 0.3544),
        CGPoint(x: 0.2626, y: 0.3537), CGPoint(x: 0.2659, y: 0.3471), CGPoint(x: 0.2752, y: 0.339),
        CGPoint(x: 0.273, y: 0.3324), CGPoint(x: 0.2697, y: 0.3316)
    ],
    "ENG": [
        CGPoint(x: 0.1651, y: 0.5529), CGPoint(x: 0.1738, y: 0.5603), CGPoint(x: 0.1978, y: 0.5765),
        CGPoint(x: 0.2049, y: 0.575), CGPoint(x: 0.2114, y: 0.5765), CGPoint(x: 0.2218, y: 0.5824),
        CGPoint(x: 0.2261, y: 0.5838), CGPoint(x: 0.237, y: 0.5904), CGPoint(x: 0.2365, y: 0.5632),
        CGPoint(x: 0.2441, y: 0.5632), CGPoint(x: 0.2468, y: 0.5728), CGPoint(x: 0.2654, y: 0.5713),
        CGPoint(x: 0.2752, y: 0.5684), CGPoint(x: 0.2866, y: 0.5478), CGPoint(x: 0.2784, y: 0.5434),
        CGPoint(x: 0.2714, y: 0.5449), CGPoint(x: 0.2594, y: 0.5426), CGPoint(x: 0.237, y: 0.5368),
        CGPoint(x: 0.2278, y: 0.5324), CGPoint(x: 0.2196, y: 0.539), CGPoint(x: 0.2092, y: 0.5346),
        CGPoint(x: 0.2021, y: 0.5382), CGPoint(x: 0.1956, y: 0.5368), CGPoint(x: 0.1651, y: 0.5529)
    ],
    "FIN": [
        CGPoint(x: 0.5373, y: 0.1985), CGPoint(x: 0.5417, y: 0.2265), CGPoint(x: 0.534, y: 0.2426),
        CGPoint(x: 0.515, y: 0.2816), CGPoint(x: 0.5166, y: 0.2956), CGPoint(x: 0.5188, y: 0.3059),
        CGPoint(x: 0.5182, y: 0.3324), CGPoint(x: 0.5275, y: 0.339), CGPoint(x: 0.5313, y: 0.3404),
        CGPoint(x: 0.5504, y: 0.3419), CGPoint(x: 0.5814, y: 0.3265), CGPoint(x: 0.5885, y: 0.3154),
        CGPoint(x: 0.5956, y: 0.2787), CGPoint(x: 0.5891, y: 0.2301), CGPoint(x: 0.5776, y: 0.189),
        CGPoint(x: 0.5733, y: 0.1485), CGPoint(x: 0.5651, y: 0.1199), CGPoint(x: 0.5607, y: 0.1169),
        CGPoint(x: 0.5471, y: 0.0949), CGPoint(x: 0.5362, y: 0.1191), CGPoint(x: 0.5199, y: 0.1162),
        CGPoint(x: 0.51, y: 0.1154), CGPoint(x: 0.5253, y: 0.1382), CGPoint(x: 0.5351, y: 0.1765),
        CGPoint(x: 0.5373, y: 0.1985)
    ],
    "GAL": [
        CGPoint(x: 0.4839, y: 0.6081), CGPoint(x: 0.485, y: 0.6213), CGPoint(x: 0.4964, y: 0.6235),
        CGPoint(x: 0.5041, y: 0.6287), CGPoint(x: 0.51, y: 0.6265), CGPoint(x: 0.5231, y: 0.6235),
        CGPoint(x: 0.5335, y: 0.6287), CGPoint(x: 0.5482, y: 0.6331), CGPoint(x: 0.5607, y: 0.65),
        CGPoint(x: 0.5684, y: 0.6581), CGPoint(x: 0.576, y: 0.6713), CGPoint(x: 0.5853, y: 0.6588),
        CGPoint(x: 0.5853, y: 0.6412), CGPoint(x: 0.5771, y: 0.611), CGPoint(x: 0.5662, y: 0.6015),
        CGPoint(x: 0.5564, y: 0.5912), CGPoint(x: 0.5438, y: 0.5963), CGPoint(x: 0.5335, y: 0.5919),
        CGPoint(x: 0.5275, y: 0.589), CGPoint(x: 0.5231, y: 0.5941), CGPoint(x: 0.515, y: 0.6015),
        CGPoint(x: 0.5062, y: 0.6022), CGPoint(x: 0.4991, y: 0.6007), CGPoint(x: 0.4932, y: 0.6059),
        CGPoint(x: 0.4839, y: 0.6081)
    ],
    "GAS": [
        CGPoint(x: 0.2267, y: 0.6529), CGPoint(x: 0.2267, y: 0.6684), CGPoint(x: 0.2283, y: 0.6735),
        CGPoint(x: 0.2256, y: 0.6721), CGPoint(x: 0.2212, y: 0.6853), CGPoint(x: 0.2212, y: 0.6912),
        CGPoint(x: 0.2147, y: 0.7088), CGPoint(x: 0.2098, y: 0.7169), CGPoint(x: 0.2076, y: 0.7213),
        CGPoint(x: 0.2163, y: 0.7338), CGPoint(x: 0.2316, y: 0.7449), CGPoint(x: 0.2387, y: 0.7463),
        CGPoint(x: 0.2463, y: 0.7507), CGPoint(x: 0.2556, y: 0.7331), CGPoint(x: 0.2621, y: 0.7199),
        CGPoint(x: 0.2724, y: 0.7169), CGPoint(x: 0.2779, y: 0.711), CGPoint(x: 0.2735, y: 0.7),
        CGPoint(x: 0.2752, y: 0.6868), CGPoint(x: 0.2665, y: 0.6824), CGPoint(x: 0.2626, y: 0.6743),
        CGPoint(x: 0.255, y: 0.6691), CGPoint(x: 0.2479, y: 0.6596), CGPoint(x: 0.2267, y: 0.6529)
    ],
    "GOL": [
        CGPoint(x: 0.261, y: 0.836), CGPoint(x: 0.3079, y: 0.8338), CGPoint(x: 0.3346, y: 0.8449),
        CGPoint(x: 0.334, y: 0.8235), CGPoint(x: 0.3493, y: 0.8199), CGPoint(x: 0.3466, y: 0.786),
        CGPoint(x: 0.3591, y: 0.7728), CGPoint(x: 0.3711, y: 0.7743), CGPoint(x: 0.3694, y: 0.7559),
        CGPoint(x: 0.3526, y: 0.7404), CGPoint(x: 0.3417, y: 0.7493), CGPoint(x: 0.3155, y: 0.7647),
        CGPoint(x: 0.3013, y: 0.7522), CGPoint(x: 0.2937, y: 0.7507), CGPoint(x: 0.2763, y: 0.7471),
        CGPoint(x: 0.2643, y: 0.7809), CGPoint(x: 0.2305, y: 0.7949), CGPoint(x: 0.2234, y: 0.8029),
        CGPoint(x: 0.2207, y: 0.8066), CGPoint(x: 0.2114, y: 0.8228), CGPoint(x: 0.2076, y: 0.8294),
        CGPoint(x: 0.2152, y: 0.8456), CGPoint(x: 0.2436, y: 0.8382), CGPoint(x: 0.2496, y: 0.8316),
        CGPoint(x: 0.261, y: 0.836)
    ],
    "GRE": [
        CGPoint(x: 0.5231, y: 0.8934), CGPoint(x: 0.5193, y: 0.8978), CGPoint(x: 0.5455, y: 0.9066),
        CGPoint(x: 0.5477, y: 0.9176), CGPoint(x: 0.5291, y: 0.914), CGPoint(x: 0.5248, y: 0.9228),
        CGPoint(x: 0.5346, y: 0.9441), CGPoint(x: 0.5471, y: 0.9493), CGPoint(x: 0.5482, y: 0.9279),
        CGPoint(x: 0.5536, y: 0.9206), CGPoint(x: 0.5645, y: 0.9147), CGPoint(x: 0.5471, y: 0.8956),
        CGPoint(x: 0.5542, y: 0.8816), CGPoint(x: 0.5482, y: 0.85), CGPoint(x: 0.5564, y: 0.8625),
        CGPoint(x: 0.5596, y: 0.8537), CGPoint(x: 0.5618, y: 0.8471), CGPoint(x: 0.5684, y: 0.825),
        CGPoint(x: 0.5406, y: 0.8368), CGPoint(x: 0.5237, y: 0.85), CGPoint(x: 0.5139, y: 0.8669),
        CGPoint(x: 0.515, y: 0.8912), CGPoint(x: 0.552, y: 0.8912), CGPoint(x: 0.5596, y: 0.8963),
        CGPoint(x: 0.552, y: 0.8912)
    ],
    "HEL": [
        CGPoint(x: 0.3389, y: 0.4985), CGPoint(x: 0.3564, y: 0.4985), CGPoint(x: 0.3651, y: 0.4926),
        CGPoint(x: 0.3754, y: 0.4978), CGPoint(x: 0.3787, y: 0.4868), CGPoint(x: 0.3787, y: 0.4772),
        CGPoint(x: 0.3782, y: 0.4684), CGPoint(x: 0.3793, y: 0.4559), CGPoint(x: 0.3776, y: 0.4485),
        CGPoint(x: 0.3771, y: 0.4404), CGPoint(x: 0.3662, y: 0.4404), CGPoint(x: 0.3482, y: 0.4544),
        CGPoint(x: 0.34, y: 0.4868), CGPoint(x: 0.3389, y: 0.4985)
    ],
    "HOL": [
        CGPoint(x: 0.3122, y: 0.5412), CGPoint(x: 0.3291, y: 0.5529), CGPoint(x: 0.3318, y: 0.5684),
        CGPoint(x: 0.3329, y: 0.5684), CGPoint(x: 0.3378, y: 0.5544), CGPoint(x: 0.3406, y: 0.5412),
        CGPoint(x: 0.3509, y: 0.5309), CGPoint(x: 0.3531, y: 0.5213), CGPoint(x: 0.3569, y: 0.5),
        CGPoint(x: 0.3422, y: 0.4993), CGPoint(x: 0.3275, y: 0.5118), CGPoint(x: 0.3188, y: 0.5368),
        CGPoint(x: 0.3122, y: 0.5412)
    ],
    "ION": [
        CGPoint(x: 0.4626, y: 0.8537), CGPoint(x: 0.455, y: 0.8721), CGPoint(x: 0.4621, y: 0.8934),
        CGPoint(x: 0.4539, y: 0.9044), CGPoint(x: 0.4392, y: 0.911), CGPoint(x: 0.4348, y: 0.9176),
        CGPoint(x: 0.431, y: 0.9449), CGPoint(x: 0.4136, y: 0.9397), CGPoint(x: 0.3945, y: 0.9257),
        CGPoint(x: 0.3831, y: 0.9235), CGPoint(x: 0.3596, y: 0.9559), CGPoint(x: 0.3667, y: 0.9978),
        CGPoint(x: 0.5607, y: 0.9846), CGPoint(x: 0.5417, y: 0.9596), CGPoint(x: 0.5318, y: 0.9493),
        CGPoint(x: 0.5286, y: 0.9331), CGPoint(x: 0.5286, y: 0.9125), CGPoint(x: 0.5493, y: 0.9162),
        CGPoint(x: 0.5411, y: 0.9059), CGPoint(x: 0.5231, y: 0.9088), CGPoint(x: 0.5155, y: 0.8934),
        CGPoint(x: 0.5073, y: 0.8757), CGPoint(x: 0.4844, y: 0.8647), CGPoint(x: 0.4757, y: 0.8662),
        CGPoint(x: 0.4626, y: 0.8537)
    ],
    "IRI": [
        CGPoint(x: 0.1607, y: 0.4779), CGPoint(x: 0.14, y: 0.5066), CGPoint(x: 0.1526, y: 0.5419),
        CGPoint(x: 0.1624, y: 0.5507), CGPoint(x: 0.1744, y: 0.5449), CGPoint(x: 0.1929, y: 0.5346),
        CGPoint(x: 0.2043, y: 0.5265), CGPoint(x: 0.2114, y: 0.5206), CGPoint(x: 0.2141, y: 0.5154),
        CGPoint(x: 0.2218, y: 0.5132), CGPoint(x: 0.2283, y: 0.5147), CGPoint(x: 0.2376, y: 0.5125),
        CGPoint(x: 0.2207, y: 0.5), CGPoint(x: 0.2136, y: 0.4912), CGPoint(x: 0.2305, y: 0.4765),
        CGPoint(x: 0.2261, y: 0.4706), CGPoint(x: 0.2452, y: 0.4647), CGPoint(x: 0.2474, y: 0.4618),
        CGPoint(x: 0.2468, y: 0.4382), CGPoint(x: 0.2185, y: 0.4331), CGPoint(x: 0.2114, y: 0.4625),
        CGPoint(x: 0.2027, y: 0.4735), CGPoint(x: 0.1918, y: 0.4735), CGPoint(x: 0.1607, y: 0.4779)
    ],
    "KIE": [
        CGPoint(x: 0.3422, y: 0.5485), CGPoint(x: 0.3689, y: 0.5647), CGPoint(x: 0.3776, y: 0.5765),
        CGPoint(x: 0.3814, y: 0.5809), CGPoint(x: 0.3874, y: 0.5765), CGPoint(x: 0.3989, y: 0.5699),
        CGPoint(x: 0.4021, y: 0.5654), CGPoint(x: 0.4016, y: 0.55), CGPoint(x: 0.4021, y: 0.5426),
        CGPoint(x: 0.4038, y: 0.5265), CGPoint(x: 0.4071, y: 0.4985), CGPoint(x: 0.3983, y: 0.4985),
        CGPoint(x: 0.4021, y: 0.4897), CGPoint(x: 0.3967, y: 0.4816), CGPoint(x: 0.3923, y: 0.4654),
        CGPoint(x: 0.3842, y: 0.4654), CGPoint(x: 0.3803, y: 0.4662), CGPoint(x: 0.3803, y: 0.4801),
        CGPoint(x: 0.3765, y: 0.4985), CGPoint(x: 0.3618, y: 0.4963), CGPoint(x: 0.3602, y: 0.5059),
        CGPoint(x: 0.3564, y: 0.5221), CGPoint(x: 0.3542, y: 0.5316), CGPoint(x: 0.3422, y: 0.5485)
    ],
    "LON": [
        CGPoint(x: 0.2839, y: 0.5375), CGPoint(x: 0.2763, y: 0.5316), CGPoint(x: 0.2817, y: 0.5221),
        CGPoint(x: 0.2948, y: 0.5044), CGPoint(x: 0.2942, y: 0.4993), CGPoint(x: 0.2779, y: 0.4926),
        CGPoint(x: 0.2719, y: 0.4963), CGPoint(x: 0.2637, y: 0.5007), CGPoint(x: 0.2583, y: 0.5022),
        CGPoint(x: 0.2506, y: 0.5184), CGPoint(x: 0.2556, y: 0.5353), CGPoint(x: 0.2583, y: 0.5404),
        CGPoint(x: 0.2643, y: 0.5426), CGPoint(x: 0.2839, y: 0.5375)
    ],
    "LVN": [
        CGPoint(x: 0.5422, y: 0.3662), CGPoint(x: 0.5417, y: 0.3809), CGPoint(x: 0.5509, y: 0.3978),
        CGPoint(x: 0.5498, y: 0.4176), CGPoint(x: 0.5433, y: 0.4243), CGPoint(x: 0.528, y: 0.4081),
        CGPoint(x: 0.5177, y: 0.439), CGPoint(x: 0.5182, y: 0.4485), CGPoint(x: 0.5242, y: 0.4551),
        CGPoint(x: 0.5395, y: 0.4743), CGPoint(x: 0.5411, y: 0.4956), CGPoint(x: 0.5395, y: 0.5051),
        CGPoint(x: 0.5569, y: 0.5265), CGPoint(x: 0.5711, y: 0.5103), CGPoint(x: 0.5754, y: 0.5037),
        CGPoint(x: 0.5847, y: 0.4985), CGPoint(x: 0.5869, y: 0.464), CGPoint(x: 0.5891, y: 0.4529),
        CGPoint(x: 0.588, y: 0.4419), CGPoint(x: 0.5902, y: 0.4059), CGPoint(x: 0.5803, y: 0.3904),
        CGPoint(x: 0.5727, y: 0.3765), CGPoint(x: 0.5607, y: 0.3765), CGPoint(x: 0.5422, y: 0.3662)
    ],
    "LVP": [
        CGPoint(x: 0.2327, y: 0.4007), CGPoint(x: 0.2387, y: 0.3978), CGPoint(x: 0.2441, y: 0.3941),
        CGPoint(x: 0.237, y: 0.4118), CGPoint(x: 0.2392, y: 0.4228), CGPoint(x: 0.2419, y: 0.4235),
        CGPoint(x: 0.2452, y: 0.4265), CGPoint(x: 0.2501, y: 0.4272), CGPoint(x: 0.2463, y: 0.4316),
        CGPoint(x: 0.2485, y: 0.4375), CGPoint(x: 0.2485, y: 0.4471), CGPoint(x: 0.249, y: 0.4581),
        CGPoint(x: 0.2447, y: 0.4728), CGPoint(x: 0.2463, y: 0.4765), CGPoint(x: 0.2599, y: 0.4838),
        CGPoint(x: 0.2599, y: 0.4581), CGPoint(x: 0.2626, y: 0.4463), CGPoint(x: 0.2626, y: 0.4294),
        CGPoint(x: 0.2539, y: 0.4103), CGPoint(x: 0.2517, y: 0.3875), CGPoint(x: 0.2348, y: 0.3838),
        CGPoint(x: 0.2294, y: 0.389), CGPoint(x: 0.2321, y: 0.3934), CGPoint(x: 0.2327, y: 0.4007)
    ],
    "MAO": [
        CGPoint(x: 0.0038, y: 0.9978), CGPoint(x: 0.0169, y: 0.975), CGPoint(x: 0.0321, y: 0.9515),
        CGPoint(x: 0.0768, y: 0.9265), CGPoint(x: 0.11, y: 0.8853), CGPoint(x: 0.1046, y: 0.8603),
        CGPoint(x: 0.0752, y: 0.8368), CGPoint(x: 0.0768, y: 0.811), CGPoint(x: 0.0746, y: 0.7956),
        CGPoint(x: 0.0855, y: 0.7647), CGPoint(x: 0.1051, y: 0.7007), CGPoint(x: 0.1122, y: 0.6787),
        CGPoint(x: 0.128, y: 0.6735), CGPoint(x: 0.1678, y: 0.7007), CGPoint(x: 0.1847, y: 0.7103),
        CGPoint(x: 0.2136, y: 0.7096), CGPoint(x: 0.2261, y: 0.6706), CGPoint(x: 0.219, y: 0.6338),
        CGPoint(x: 0.2158, y: 0.614), CGPoint(x: 0.1929, y: 0.5926), CGPoint(x: 0.1962, y: 0.5787),
        CGPoint(x: 0.1182, y: 0.5125), CGPoint(x: 0.0452, y: 0.4993), CGPoint(x: 0.0043, y: 0.5103),
        CGPoint(x: 0.0038, y: 0.9978)
    ],
    "MAR": [
        CGPoint(x: 0.2975, y: 0.6838), CGPoint(x: 0.2932, y: 0.7081), CGPoint(x: 0.2866, y: 0.7154),
        CGPoint(x: 0.279, y: 0.7125), CGPoint(x: 0.2724, y: 0.7191), CGPoint(x: 0.2626, y: 0.7228),
        CGPoint(x: 0.2572, y: 0.7338), CGPoint(x: 0.2479, y: 0.7515), CGPoint(x: 0.261, y: 0.7632),
        CGPoint(x: 0.267, y: 0.7654), CGPoint(x: 0.2697, y: 0.7544), CGPoint(x: 0.2812, y: 0.7434),
        CGPoint(x: 0.2932, y: 0.7493), CGPoint(x: 0.3013, y: 0.7507), CGPoint(x: 0.3122, y: 0.7632),
        CGPoint(x: 0.3313, y: 0.7522), CGPoint(x: 0.328, y: 0.7397), CGPoint(x: 0.3286, y: 0.7287),
        CGPoint(x: 0.3264, y: 0.7184), CGPoint(x: 0.3291, y: 0.7081), CGPoint(x: 0.3264, y: 0.7007),
        CGPoint(x: 0.3286, y: 0.6897), CGPoint(x: 0.3237, y: 0.689), CGPoint(x: 0.315, y: 0.6868),
        CGPoint(x: 0.2975, y: 0.6838)
    ],
    "MOS": [
        CGPoint(x: 0.9956, y: 0.1096), CGPoint(x: 0.8425, y: 0.261), CGPoint(x: 0.7602, y: 0.3051),
        CGPoint(x: 0.6752, y: 0.3397), CGPoint(x: 0.631, y: 0.3941), CGPoint(x: 0.5912, y: 0.4515),
        CGPoint(x: 0.5776, y: 0.5044), CGPoint(x: 0.5591, y: 0.5279), CGPoint(x: 0.5705, y: 0.5566),
        CGPoint(x: 0.6632, y: 0.5294), CGPoint(x: 0.7122, y: 0.5221), CGPoint(x: 0.7591, y: 0.5118),
        CGPoint(x: 0.8054, y: 0.5794), CGPoint(x: 0.8599, y: 0.6176), CGPoint(x: 0.8828, y: 0.5809),
        CGPoint(x: 0.9264, y: 0.5831), CGPoint(x: 0.9041, y: 0.6397), CGPoint(x: 0.9378, y: 0.6603),
        CGPoint(x: 0.9547, y: 0.6875), CGPoint(x: 0.982, y: 0.6838), CGPoint(x: 0.9613, y: 0.7037),
        CGPoint(x: 0.9782, y: 0.7235), CGPoint(x: 0.9956, y: 0.7699), CGPoint(x: 0.9962, y: 0.2544),
        CGPoint(x: 0.9956, y: 0.1096)
    ],
    "MUN": [
        CGPoint(x: 0.3406, y: 0.625), CGPoint(x: 0.3427, y: 0.6331), CGPoint(x: 0.3411, y: 0.6434),
        CGPoint(x: 0.34, y: 0.6529), CGPoint(x: 0.3531, y: 0.6522), CGPoint(x: 0.3689, y: 0.6544),
        CGPoint(x: 0.3749, y: 0.6559), CGPoint(x: 0.3809, y: 0.6603), CGPoint(x: 0.3945, y: 0.6588),
        CGPoint(x: 0.4114, y: 0.661), CGPoint(x: 0.4114, y: 0.6507), CGPoint(x: 0.4169, y: 0.6449),
        CGPoint(x: 0.4207, y: 0.6279), CGPoint(x: 0.4103, y: 0.611), CGPoint(x: 0.4098, y: 0.5926),
        CGPoint(x: 0.4136, y: 0.589), CGPoint(x: 0.4201, y: 0.5853), CGPoint(x: 0.4152, y: 0.5632),
        CGPoint(x: 0.4032, y: 0.5691), CGPoint(x: 0.3972, y: 0.5735), CGPoint(x: 0.3885, y: 0.5787),
        CGPoint(x: 0.3618, y: 0.5985), CGPoint(x: 0.3498, y: 0.6191), CGPoint(x: 0.3406, y: 0.625)
    ],
    "NAF": [
        CGPoint(x: 0.0114, y: 0.9978), CGPoint(x: 0.3188, y: 0.9978), CGPoint(x: 0.3259, y: 0.9272),
        CGPoint(x: 0.3133, y: 0.9228), CGPoint(x: 0.2964, y: 0.9206), CGPoint(x: 0.285, y: 0.9243),
        CGPoint(x: 0.2795, y: 0.9257), CGPoint(x: 0.2675, y: 0.9162), CGPoint(x: 0.2381, y: 0.9132),
        CGPoint(x: 0.2272, y: 0.9118), CGPoint(x: 0.1994, y: 0.9176), CGPoint(x: 0.1923, y: 0.9213),
        CGPoint(x: 0.1874, y: 0.9191), CGPoint(x: 0.1716, y: 0.9265), CGPoint(x: 0.1536, y: 0.9243),
        CGPoint(x: 0.1455, y: 0.9147), CGPoint(x: 0.1395, y: 0.9162), CGPoint(x: 0.1204, y: 0.9088),
        CGPoint(x: 0.1111, y: 0.8882), CGPoint(x: 0.1013, y: 0.8985), CGPoint(x: 0.0528, y: 0.9324),
        CGPoint(x: 0.0381, y: 0.9441), CGPoint(x: 0.0332, y: 0.9522), CGPoint(x: 0.0114, y: 0.9978)
    ],
    "NAO": [
        CGPoint(x: 0.0038, y: 0.0037), CGPoint(x: 0.0872, y: 0.4971), CGPoint(x: 0.1378, y: 0.5059),
        CGPoint(x: 0.1596, y: 0.4662), CGPoint(x: 0.1705, y: 0.4441), CGPoint(x: 0.1776, y: 0.414),
        CGPoint(x: 0.1989, y: 0.4074), CGPoint(x: 0.2174, y: 0.3949), CGPoint(x: 0.2278, y: 0.411),
        CGPoint(x: 0.2332, y: 0.4346), CGPoint(x: 0.2408, y: 0.4257), CGPoint(x: 0.2425, y: 0.3919),
        CGPoint(x: 0.2327, y: 0.4022), CGPoint(x: 0.2365, y: 0.3772), CGPoint(x: 0.2436, y: 0.3441),
        CGPoint(x: 0.2599, y: 0.3118), CGPoint(x: 0.2654, y: 0.2132), CGPoint(x: 0.2316, y: 0.1412),
        CGPoint(x: 0.1803, y: 0.1176), CGPoint(x: 0.1684, y: 0.1029), CGPoint(x: 0.1738, y: 0.0801),
        CGPoint(x: 0.1874, y: 0.0824), CGPoint(x: 0.1814, y: 0.0596), CGPoint(x: 0.1967, y: 0.0338),
        CGPoint(x: 0.0038, y: 0.0037)
    ],
    "NAP": [
        CGPoint(x: 0.4545, y: 0.8662), CGPoint(x: 0.4436, y: 0.8566), CGPoint(x: 0.4414, y: 0.8463),
        CGPoint(x: 0.431, y: 0.8309), CGPoint(x: 0.4239, y: 0.8279), CGPoint(x: 0.418, y: 0.836),
        CGPoint(x: 0.4201, y: 0.8426), CGPoint(x: 0.4218, y: 0.8471), CGPoint(x: 0.4299, y: 0.85),
        CGPoint(x: 0.4338, y: 0.8603), CGPoint(x: 0.443, y: 0.8728), CGPoint(x: 0.4479, y: 0.8904),
        CGPoint(x: 0.4479, y: 0.8949), CGPoint(x: 0.443, y: 0.9074), CGPoint(x: 0.4408, y: 0.9169),
        CGPoint(x: 0.4474, y: 0.9162), CGPoint(x: 0.4523, y: 0.9044), CGPoint(x: 0.4545, y: 0.8963),
        CGPoint(x: 0.4599, y: 0.8934), CGPoint(x: 0.4615, y: 0.886), CGPoint(x: 0.4539, y: 0.8721),
        CGPoint(x: 0.4545, y: 0.8662)
    ],
    "NTH": [
        CGPoint(x: 0.2632, y: 0.3529), CGPoint(x: 0.2752, y: 0.3544), CGPoint(x: 0.2812, y: 0.3721),
        CGPoint(x: 0.2741, y: 0.4147), CGPoint(x: 0.2757, y: 0.4412), CGPoint(x: 0.279, y: 0.4684),
        CGPoint(x: 0.279, y: 0.4904), CGPoint(x: 0.2926, y: 0.4949), CGPoint(x: 0.2828, y: 0.5235),
        CGPoint(x: 0.2844, y: 0.5368), CGPoint(x: 0.2959, y: 0.5441), CGPoint(x: 0.3242, y: 0.5184),
        CGPoint(x: 0.3378, y: 0.486), CGPoint(x: 0.3776, y: 0.4375), CGPoint(x: 0.3765, y: 0.4103),
        CGPoint(x: 0.3749, y: 0.3846), CGPoint(x: 0.3624, y: 0.3669), CGPoint(x: 0.3673, y: 0.3485),
        CGPoint(x: 0.3624, y: 0.3412), CGPoint(x: 0.3629, y: 0.3331), CGPoint(x: 0.364, y: 0.3176),
        CGPoint(x: 0.37, y: 0.2853), CGPoint(x: 0.3035, y: 0.3103), CGPoint(x: 0.2724, y: 0.3434),
        CGPoint(x: 0.2632, y: 0.3529)
    ],
    "NWG": [
        CGPoint(x: 0.1989, y: 0.0037), CGPoint(x: 0.2032, y: 0.0625), CGPoint(x: 0.2032, y: 0.0787),
        CGPoint(x: 0.2098, y: 0.0721), CGPoint(x: 0.218, y: 0.0779), CGPoint(x: 0.2267, y: 0.0846),
        CGPoint(x: 0.237, y: 0.0868), CGPoint(x: 0.2485, y: 0.1257), CGPoint(x: 0.2572, y: 0.186),
        CGPoint(x: 0.2626, y: 0.3066), CGPoint(x: 0.2741, y: 0.3309), CGPoint(x: 0.3013, y: 0.3088),
        CGPoint(x: 0.3716, y: 0.2831), CGPoint(x: 0.3934, y: 0.2647), CGPoint(x: 0.4098, y: 0.25),
        CGPoint(x: 0.419, y: 0.2404), CGPoint(x: 0.4419, y: 0.2), CGPoint(x: 0.4615, y: 0.1647),
        CGPoint(x: 0.4823, y: 0.1265), CGPoint(x: 0.485, y: 0.1154), CGPoint(x: 0.4926, y: 0.1044),
        CGPoint(x: 0.522, y: 0.0816), CGPoint(x: 0.5318, y: 0.0603), CGPoint(x: 0.5335, y: 0.0037),
        CGPoint(x: 0.1989, y: 0.0037)
    ],
    "NWY": [
        CGPoint(x: 0.5466, y: 0.0684), CGPoint(x: 0.5373, y: 0.0706), CGPoint(x: 0.5111, y: 0.0941),
        CGPoint(x: 0.4893, y: 0.1081), CGPoint(x: 0.4828, y: 0.1279), CGPoint(x: 0.4441, y: 0.1978),
        CGPoint(x: 0.4196, y: 0.2419), CGPoint(x: 0.4021, y: 0.2588), CGPoint(x: 0.3869, y: 0.2684),
        CGPoint(x: 0.3727, y: 0.2838), CGPoint(x: 0.3662, y: 0.3316), CGPoint(x: 0.3624, y: 0.3485),
        CGPoint(x: 0.3689, y: 0.3772), CGPoint(x: 0.413, y: 0.3588), CGPoint(x: 0.425, y: 0.3574),
        CGPoint(x: 0.4354, y: 0.2963), CGPoint(x: 0.4447, y: 0.2397), CGPoint(x: 0.4621, y: 0.1941),
        CGPoint(x: 0.4893, y: 0.1375), CGPoint(x: 0.5199, y: 0.111), CGPoint(x: 0.5504, y: 0.0882),
        CGPoint(x: 0.5754, y: 0.0934), CGPoint(x: 0.5635, y: 0.0721), CGPoint(x: 0.5531, y: 0.0654),
        CGPoint(x: 0.5466, y: 0.0684)
    ],
    "PAR": [
        CGPoint(x: 0.2539, y: 0.5956), CGPoint(x: 0.2534, y: 0.6206), CGPoint(x: 0.2501, y: 0.6588),
        CGPoint(x: 0.2539, y: 0.6647), CGPoint(x: 0.2654, y: 0.6706), CGPoint(x: 0.2735, y: 0.6581),
        CGPoint(x: 0.2768, y: 0.6434), CGPoint(x: 0.2839, y: 0.6382), CGPoint(x: 0.2872, y: 0.6331),
        CGPoint(x: 0.2926, y: 0.6287), CGPoint(x: 0.297, y: 0.6235), CGPoint(x: 0.3024, y: 0.6191),
        CGPoint(x: 0.3084, y: 0.6044), CGPoint(x: 0.2932, y: 0.5963), CGPoint(x: 0.2833, y: 0.5919),
        CGPoint(x: 0.2757, y: 0.5956), CGPoint(x: 0.2621, y: 0.5971), CGPoint(x: 0.2539, y: 0.5956)
    ],
    "PIC": [
        CGPoint(x: 0.2812, y: 0.5632), CGPoint(x: 0.2741, y: 0.5706), CGPoint(x: 0.2686, y: 0.5713),
        CGPoint(x: 0.2626, y: 0.575), CGPoint(x: 0.2626, y: 0.5765), CGPoint(x: 0.2648, y: 0.5779),
        CGPoint(x: 0.2648, y: 0.5794), CGPoint(x: 0.2572, y: 0.5809), CGPoint(x: 0.2539, y: 0.5949),
        CGPoint(x: 0.2741, y: 0.5934), CGPoint(x: 0.2833, y: 0.5897), CGPoint(x: 0.2932, y: 0.5934),
        CGPoint(x: 0.3095, y: 0.6022), CGPoint(x: 0.3133, y: 0.5897), CGPoint(x: 0.2997, y: 0.5779),
        CGPoint(x: 0.2812, y: 0.5632)
    ],
    "PIE": [
        CGPoint(x: 0.3318, y: 0.6941), CGPoint(x: 0.3308, y: 0.7015), CGPoint(x: 0.3329, y: 0.7096),
        CGPoint(x: 0.3302, y: 0.7176), CGPoint(x: 0.3324, y: 0.7287), CGPoint(x: 0.3329, y: 0.7456),
        CGPoint(x: 0.3357, y: 0.7493), CGPoint(x: 0.3438, y: 0.7456), CGPoint(x: 0.3558, y: 0.7382),
        CGPoint(x: 0.3673, y: 0.7471), CGPoint(x: 0.37, y: 0.739), CGPoint(x: 0.3673, y: 0.7287),
        CGPoint(x: 0.3771, y: 0.7066), CGPoint(x: 0.3765, y: 0.6978), CGPoint(x: 0.3656, y: 0.6956),
        CGPoint(x: 0.3575, y: 0.7037), CGPoint(x: 0.346, y: 0.6949), CGPoint(x: 0.3318, y: 0.6941)
    ],
    "POR": [
        CGPoint(x: 0.1084, y: 0.7154), CGPoint(x: 0.1035, y: 0.7176), CGPoint(x: 0.1008, y: 0.7287),
        CGPoint(x: 0.0948, y: 0.7478), CGPoint(x: 0.085, y: 0.7684), CGPoint(x: 0.0768, y: 0.775),
        CGPoint(x: 0.0746, y: 0.789), CGPoint(x: 0.0752, y: 0.7934), CGPoint(x: 0.0806, y: 0.8007),
        CGPoint(x: 0.0779, y: 0.811), CGPoint(x: 0.0757, y: 0.8221), CGPoint(x: 0.0719, y: 0.8324),
        CGPoint(x: 0.079, y: 0.8382), CGPoint(x: 0.0855, y: 0.8412), CGPoint(x: 0.0915, y: 0.839),
        CGPoint(x: 0.0959, y: 0.8272), CGPoint(x: 0.1046, y: 0.811), CGPoint(x: 0.1051, y: 0.8022),
        CGPoint(x: 0.1079, y: 0.7926), CGPoint(x: 0.1084, y: 0.7794), CGPoint(x: 0.1166, y: 0.7684),
        CGPoint(x: 0.1275, y: 0.7426), CGPoint(x: 0.1346, y: 0.7301), CGPoint(x: 0.1182, y: 0.7221),
        CGPoint(x: 0.1084, y: 0.7154)
    ],
    "PRU": [
        CGPoint(x: 0.5182, y: 0.4544), CGPoint(x: 0.5155, y: 0.4757), CGPoint(x: 0.5079, y: 0.4787),
        CGPoint(x: 0.5057, y: 0.4853), CGPoint(x: 0.5019, y: 0.4912), CGPoint(x: 0.4893, y: 0.4926),
        CGPoint(x: 0.4877, y: 0.486), CGPoint(x: 0.4648, y: 0.4941), CGPoint(x: 0.4441, y: 0.5022),
        CGPoint(x: 0.4463, y: 0.5243), CGPoint(x: 0.449, y: 0.5353), CGPoint(x: 0.4506, y: 0.5456),
        CGPoint(x: 0.4566, y: 0.5485), CGPoint(x: 0.4719, y: 0.55), CGPoint(x: 0.479, y: 0.5493),
        CGPoint(x: 0.4828, y: 0.5397), CGPoint(x: 0.4926, y: 0.5257), CGPoint(x: 0.5171, y: 0.5162),
        CGPoint(x: 0.5373, y: 0.4971), CGPoint(x: 0.5384, y: 0.4882), CGPoint(x: 0.5384, y: 0.4853),
        CGPoint(x: 0.5351, y: 0.4743), CGPoint(x: 0.5264, y: 0.4691), CGPoint(x: 0.5182, y: 0.4544)
    ],
    "ROM": [
        CGPoint(x: 0.4239, y: 0.8243), CGPoint(x: 0.412, y: 0.8096), CGPoint(x: 0.4071, y: 0.8029),
        CGPoint(x: 0.4054, y: 0.7934), CGPoint(x: 0.4027, y: 0.7816), CGPoint(x: 0.3891, y: 0.7912),
        CGPoint(x: 0.3858, y: 0.7985), CGPoint(x: 0.3918, y: 0.8103), CGPoint(x: 0.4038, y: 0.8272),
        CGPoint(x: 0.4114, y: 0.8287), CGPoint(x: 0.4174, y: 0.8309), CGPoint(x: 0.4239, y: 0.8243)
    ],
    "RUH": [
        CGPoint(x: 0.3417, y: 0.5515), CGPoint(x: 0.3378, y: 0.5662), CGPoint(x: 0.3351, y: 0.5743),
        CGPoint(x: 0.3378, y: 0.5941), CGPoint(x: 0.334, y: 0.6015), CGPoint(x: 0.3389, y: 0.6213),
        CGPoint(x: 0.3482, y: 0.6176), CGPoint(x: 0.3536, y: 0.6074), CGPoint(x: 0.3645, y: 0.5926),
        CGPoint(x: 0.3754, y: 0.589), CGPoint(x: 0.3793, y: 0.5853), CGPoint(x: 0.3727, y: 0.5728),
        CGPoint(x: 0.3498, y: 0.5551), CGPoint(x: 0.3417, y: 0.5515)
    ],
    "RUM": [
        CGPoint(x: 0.5896, y: 0.6493), CGPoint(x: 0.5869, y: 0.664), CGPoint(x: 0.5793, y: 0.6735),
        CGPoint(x: 0.5836, y: 0.6846), CGPoint(x: 0.5912, y: 0.7088), CGPoint(x: 0.5782, y: 0.7206),
        CGPoint(x: 0.5493, y: 0.7301), CGPoint(x: 0.5406, y: 0.75), CGPoint(x: 0.5444, y: 0.7537),
        CGPoint(x: 0.5482, y: 0.7581), CGPoint(x: 0.5645, y: 0.761), CGPoint(x: 0.5836, y: 0.7603),
        CGPoint(x: 0.5951, y: 0.7551), CGPoint(x: 0.6234, y: 0.7566), CGPoint(x: 0.6256, y: 0.7368),
        CGPoint(x: 0.6321, y: 0.7265), CGPoint(x: 0.6332, y: 0.7169), CGPoint(x: 0.618, y: 0.7191),
        CGPoint(x: 0.6114, y: 0.7), CGPoint(x: 0.612, y: 0.6912), CGPoint(x: 0.606, y: 0.6706),
        CGPoint(x: 0.5896, y: 0.6493)
    ],
    "SER": [
        CGPoint(x: 0.5417, y: 0.8316), CGPoint(x: 0.5384, y: 0.8221), CGPoint(x: 0.5422, y: 0.8162),
        CGPoint(x: 0.5389, y: 0.7971), CGPoint(x: 0.5395, y: 0.7904), CGPoint(x: 0.5422, y: 0.7838),
        CGPoint(x: 0.5373, y: 0.7706), CGPoint(x: 0.5373, y: 0.7574), CGPoint(x: 0.5351, y: 0.7449),
        CGPoint(x: 0.5318, y: 0.7441), CGPoint(x: 0.5171, y: 0.7426), CGPoint(x: 0.51, y: 0.7397),
        CGPoint(x: 0.5046, y: 0.7434), CGPoint(x: 0.497, y: 0.7434), CGPoint(x: 0.4953, y: 0.7463),
        CGPoint(x: 0.497, y: 0.7603), CGPoint(x: 0.4948, y: 0.7691), CGPoint(x: 0.4953, y: 0.7853),
        CGPoint(x: 0.5117, y: 0.8029), CGPoint(x: 0.5155, y: 0.8184), CGPoint(x: 0.516, y: 0.825),
        CGPoint(x: 0.5171, y: 0.836), CGPoint(x: 0.5226, y: 0.8375), CGPoint(x: 0.5417, y: 0.8316)
    ],
    "SEV": [
        CGPoint(x: 0.637, y: 0.6838), CGPoint(x: 0.6637, y: 0.6721), CGPoint(x: 0.685, y: 0.6875),
        CGPoint(x: 0.6942, y: 0.725), CGPoint(x: 0.7177, y: 0.7029), CGPoint(x: 0.6953, y: 0.6868),
        CGPoint(x: 0.7378, y: 0.6419), CGPoint(x: 0.7378, y: 0.6596), CGPoint(x: 0.7351, y: 0.6926),
        CGPoint(x: 0.7498, y: 0.7059), CGPoint(x: 0.8076, y: 0.7662), CGPoint(x: 0.8556, y: 0.7904),
        CGPoint(x: 0.9144, y: 0.7801), CGPoint(x: 0.9231, y: 0.7662), CGPoint(x: 0.9046, y: 0.7162),
        CGPoint(x: 0.8648, y: 0.664), CGPoint(x: 0.8583, y: 0.625), CGPoint(x: 0.8027, y: 0.5794),
        CGPoint(x: 0.7673, y: 0.5176), CGPoint(x: 0.7166, y: 0.5132), CGPoint(x: 0.6741, y: 0.5397),
        CGPoint(x: 0.6463, y: 0.6316), CGPoint(x: 0.6185, y: 0.6713), CGPoint(x: 0.6332, y: 0.711),
        CGPoint(x: 0.637, y: 0.6838)
    ],
    "SIL": [
        CGPoint(x: 0.4169, y: 0.5625), CGPoint(x: 0.4223, y: 0.5838), CGPoint(x: 0.437, y: 0.5787),
        CGPoint(x: 0.449, y: 0.5779), CGPoint(x: 0.4626, y: 0.5919), CGPoint(x: 0.4741, y: 0.5985),
        CGPoint(x: 0.4953, y: 0.5978), CGPoint(x: 0.4866, y: 0.5824), CGPoint(x: 0.4795, y: 0.5522),
        CGPoint(x: 0.4599, y: 0.5522), CGPoint(x: 0.4534, y: 0.5507), CGPoint(x: 0.449, y: 0.5485),
        CGPoint(x: 0.4452, y: 0.5522), CGPoint(x: 0.4397, y: 0.5559), CGPoint(x: 0.4169, y: 0.5625)
    ],
    "SKA": [
        CGPoint(x: 0.3776, y: 0.3846), CGPoint(x: 0.3809, y: 0.4154), CGPoint(x: 0.382, y: 0.4154),
        CGPoint(x: 0.3923, y: 0.4088), CGPoint(x: 0.4011, y: 0.4029), CGPoint(x: 0.4071, y: 0.4022),
        CGPoint(x: 0.4081, y: 0.4066), CGPoint(x: 0.4071, y: 0.4154), CGPoint(x: 0.4038, y: 0.425),
        CGPoint(x: 0.4076, y: 0.4316), CGPoint(x: 0.4103, y: 0.4375), CGPoint(x: 0.4147, y: 0.439),
        CGPoint(x: 0.4256, y: 0.4419), CGPoint(x: 0.4278, y: 0.4309), CGPoint(x: 0.4223, y: 0.4096),
        CGPoint(x: 0.418, y: 0.3882), CGPoint(x: 0.4158, y: 0.3743), CGPoint(x: 0.4136, y: 0.361),
        CGPoint(x: 0.4049, y: 0.3676), CGPoint(x: 0.3945, y: 0.3743), CGPoint(x: 0.3776, y: 0.3846)
    ],
    "SMY": [
        CGPoint(x: 0.7853, y: 0.8221), CGPoint(x: 0.7444, y: 0.839), CGPoint(x: 0.715, y: 0.864),
        CGPoint(x: 0.6899, y: 0.8662), CGPoint(x: 0.6572, y: 0.8787), CGPoint(x: 0.6408, y: 0.8787),
        CGPoint(x: 0.6288, y: 0.8809), CGPoint(x: 0.6125, y: 0.8735), CGPoint(x: 0.6092, y: 0.8868),
        CGPoint(x: 0.6081, y: 0.8993), CGPoint(x: 0.6141, y: 0.9147), CGPoint(x: 0.619, y: 0.9243),
        CGPoint(x: 0.6288, y: 0.9309), CGPoint(x: 0.6321, y: 0.9331), CGPoint(x: 0.6343, y: 0.9382),
        CGPoint(x: 0.6441, y: 0.9397), CGPoint(x: 0.6566, y: 0.95), CGPoint(x: 0.6741, y: 0.9279),
        CGPoint(x: 0.7024, y: 0.9426), CGPoint(x: 0.7302, y: 0.9191), CGPoint(x: 0.752, y: 0.9103),
        CGPoint(x: 0.7673, y: 0.8735), CGPoint(x: 0.7874, y: 0.8618), CGPoint(x: 0.7858, y: 0.8368),
        CGPoint(x: 0.7853, y: 0.8221)
    ],
    "SPA": [
        CGPoint(x: 0.1041, y: 0.7118), CGPoint(x: 0.1193, y: 0.7176), CGPoint(x: 0.1389, y: 0.7346),
        CGPoint(x: 0.1155, y: 0.7765), CGPoint(x: 0.1111, y: 0.7912), CGPoint(x: 0.1068, y: 0.8191),
        CGPoint(x: 0.1057, y: 0.8596), CGPoint(x: 0.1188, y: 0.8743), CGPoint(x: 0.1362, y: 0.8728),
        CGPoint(x: 0.158, y: 0.8801), CGPoint(x: 0.1771, y: 0.8713), CGPoint(x: 0.2092, y: 0.8463),
        CGPoint(x: 0.2098, y: 0.8235), CGPoint(x: 0.2201, y: 0.8059), CGPoint(x: 0.2403, y: 0.7904),
        CGPoint(x: 0.2675, y: 0.7699), CGPoint(x: 0.2381, y: 0.7507), CGPoint(x: 0.219, y: 0.7419),
        CGPoint(x: 0.2027, y: 0.7213), CGPoint(x: 0.1842, y: 0.7118), CGPoint(x: 0.1694, y: 0.7037),
        CGPoint(x: 0.1378, y: 0.6846), CGPoint(x: 0.1117, y: 0.6801), CGPoint(x: 0.1062, y: 0.7007),
        CGPoint(x: 0.1041, y: 0.7118)
    ],
    "STP": [
        CGPoint(x: 0.758, y: 0.0037), CGPoint(x: 0.7504, y: 0.0368), CGPoint(x: 0.7324, y: 0.0824),
        CGPoint(x: 0.7231, y: 0.0515), CGPoint(x: 0.7062, y: 0.0985), CGPoint(x: 0.6752, y: 0.0868),
        CGPoint(x: 0.685, y: 0.1294), CGPoint(x: 0.6583, y: 0.1757), CGPoint(x: 0.6752, y: 0.2),
        CGPoint(x: 0.6441, y: 0.2096), CGPoint(x: 0.6272, y: 0.214), CGPoint(x: 0.6038, y: 0.1691),
        CGPoint(x: 0.6141, y: 0.1618), CGPoint(x: 0.6338, y: 0.111), CGPoint(x: 0.582, y: 0.0897),
        CGPoint(x: 0.5754, y: 0.1485), CGPoint(x: 0.5978, y: 0.2816), CGPoint(x: 0.6021, y: 0.339),
        CGPoint(x: 0.5618, y: 0.3574), CGPoint(x: 0.5891, y: 0.3985), CGPoint(x: 0.6512, y: 0.3853),
        CGPoint(x: 0.7215, y: 0.3191), CGPoint(x: 0.8294, y: 0.2676), CGPoint(x: 0.9716, y: 0.1368),
        CGPoint(x: 0.758, y: 0.0037)
    ],
    "SWE": [
        CGPoint(x: 0.5084, y: 0.1235), CGPoint(x: 0.4997, y: 0.1331), CGPoint(x: 0.4921, y: 0.1412),
        CGPoint(x: 0.4774, y: 0.1713), CGPoint(x: 0.4648, y: 0.1963), CGPoint(x: 0.4539, y: 0.2382),
        CGPoint(x: 0.4403, y: 0.2551), CGPoint(x: 0.4387, y: 0.2919), CGPoint(x: 0.4376, y: 0.311),
        CGPoint(x: 0.4299, y: 0.3522), CGPoint(x: 0.4174, y: 0.3743), CGPoint(x: 0.4239, y: 0.4125),
        CGPoint(x: 0.4288, y: 0.4529), CGPoint(x: 0.4436, y: 0.4529), CGPoint(x: 0.461, y: 0.4463),
        CGPoint(x: 0.4686, y: 0.4096), CGPoint(x: 0.4708, y: 0.3875), CGPoint(x: 0.4724, y: 0.3816),
        CGPoint(x: 0.4899, y: 0.364), CGPoint(x: 0.4812, y: 0.3309), CGPoint(x: 0.4839, y: 0.286),
        CGPoint(x: 0.5144, y: 0.2257), CGPoint(x: 0.5335, y: 0.1971), CGPoint(x: 0.5248, y: 0.1449),
        CGPoint(x: 0.5084, y: 0.1235)
    ],
    "SYR": [
        CGPoint(x: 0.9956, y: 0.7919), CGPoint(x: 0.9863, y: 0.8074), CGPoint(x: 0.9613, y: 0.8162),
        CGPoint(x: 0.9477, y: 0.8346), CGPoint(x: 0.9133, y: 0.8676), CGPoint(x: 0.9019, y: 0.8691),
        CGPoint(x: 0.8975, y: 0.8699), CGPoint(x: 0.8915, y: 0.8691), CGPoint(x: 0.8381, y: 0.8618),
        CGPoint(x: 0.7978, y: 0.861), CGPoint(x: 0.7656, y: 0.8787), CGPoint(x: 0.7591, y: 0.8985),
        CGPoint(x: 0.7526, y: 0.9132), CGPoint(x: 0.7515, y: 0.9191), CGPoint(x: 0.7482, y: 0.9287),
        CGPoint(x: 0.7509, y: 0.9478), CGPoint(x: 0.7542, y: 0.9544), CGPoint(x: 0.7553, y: 0.9596),
        CGPoint(x: 0.7558, y: 0.9721), CGPoint(x: 0.7569, y: 0.9846), CGPoint(x: 0.7569, y: 0.9978),
        CGPoint(x: 0.9962, y: 0.9978), CGPoint(x: 0.9962, y: 0.811), CGPoint(x: 0.9956, y: 0.7919)
    ],
    "TRI": [
        CGPoint(x: 0.4403, y: 0.6772), CGPoint(x: 0.4348, y: 0.686), CGPoint(x: 0.419, y: 0.6904),
        CGPoint(x: 0.4207, y: 0.7132), CGPoint(x: 0.4196, y: 0.7221), CGPoint(x: 0.4218, y: 0.7346),
        CGPoint(x: 0.4256, y: 0.7301), CGPoint(x: 0.4327, y: 0.7235), CGPoint(x: 0.431, y: 0.7434),
        CGPoint(x: 0.4447, y: 0.7625), CGPoint(x: 0.4517, y: 0.7713), CGPoint(x: 0.4643, y: 0.7824),
        CGPoint(x: 0.4735, y: 0.7926), CGPoint(x: 0.4904, y: 0.8088), CGPoint(x: 0.4986, y: 0.7963),
        CGPoint(x: 0.4904, y: 0.775), CGPoint(x: 0.4932, y: 0.761), CGPoint(x: 0.4932, y: 0.7404),
        CGPoint(x: 0.4866, y: 0.7346), CGPoint(x: 0.4812, y: 0.7213), CGPoint(x: 0.4708, y: 0.7132),
        CGPoint(x: 0.4621, y: 0.6875), CGPoint(x: 0.4512, y: 0.6926), CGPoint(x: 0.4403, y: 0.6772)
    ],
    "TUN": [
        CGPoint(x: 0.3226, y: 0.9978), CGPoint(x: 0.3607, y: 0.9978), CGPoint(x: 0.3651, y: 0.9971),
        CGPoint(x: 0.3673, y: 0.9912), CGPoint(x: 0.3667, y: 0.9735), CGPoint(x: 0.3602, y: 0.964),
        CGPoint(x: 0.3586, y: 0.9559), CGPoint(x: 0.3673, y: 0.9412), CGPoint(x: 0.3684, y: 0.9338),
        CGPoint(x: 0.3651, y: 0.9338), CGPoint(x: 0.3575, y: 0.9382), CGPoint(x: 0.3547, y: 0.9294),
        CGPoint(x: 0.3438, y: 0.9243), CGPoint(x: 0.3351, y: 0.9265), CGPoint(x: 0.3302, y: 0.9287),
        CGPoint(x: 0.3237, y: 0.9478), CGPoint(x: 0.3226, y: 0.9978)
    ],
    "TUS": [
        CGPoint(x: 0.3722, y: 0.7412), CGPoint(x: 0.3694, y: 0.7485), CGPoint(x: 0.3711, y: 0.7581),
        CGPoint(x: 0.3722, y: 0.7728), CGPoint(x: 0.3836, y: 0.7963), CGPoint(x: 0.3918, y: 0.786),
        CGPoint(x: 0.4016, y: 0.7787), CGPoint(x: 0.3902, y: 0.7574), CGPoint(x: 0.3782, y: 0.7471),
        CGPoint(x: 0.3722, y: 0.7412)
    ],
    "TYR": [
        CGPoint(x: 0.3705, y: 0.6596), CGPoint(x: 0.3809, y: 0.6824), CGPoint(x: 0.3798, y: 0.7),
        CGPoint(x: 0.3858, y: 0.7096), CGPoint(x: 0.3934, y: 0.7022), CGPoint(x: 0.3951, y: 0.6949),
        CGPoint(x: 0.4081, y: 0.6897), CGPoint(x: 0.4163, y: 0.689), CGPoint(x: 0.419, y: 0.6853),
        CGPoint(x: 0.4239, y: 0.6831), CGPoint(x: 0.4305, y: 0.6831), CGPoint(x: 0.4354, y: 0.6831),
        CGPoint(x: 0.4387, y: 0.6721), CGPoint(x: 0.4403, y: 0.6434), CGPoint(x: 0.4239, y: 0.6441),
        CGPoint(x: 0.419, y: 0.6485), CGPoint(x: 0.4152, y: 0.6515), CGPoint(x: 0.4125, y: 0.6654),
        CGPoint(x: 0.4081, y: 0.6647), CGPoint(x: 0.4011, y: 0.664), CGPoint(x: 0.3896, y: 0.664),
        CGPoint(x: 0.3793, y: 0.6647), CGPoint(x: 0.3705, y: 0.6596)
    ],
    "TYS": [
        CGPoint(x: 0.3384, y: 0.8801), CGPoint(x: 0.3417, y: 0.9074), CGPoint(x: 0.34, y: 0.9235),
        CGPoint(x: 0.3569, y: 0.9375), CGPoint(x: 0.3711, y: 0.9279), CGPoint(x: 0.3945, y: 0.9081),
        CGPoint(x: 0.412, y: 0.911), CGPoint(x: 0.4294, y: 0.911), CGPoint(x: 0.4468, y: 0.8949),
        CGPoint(x: 0.4419, y: 0.8728), CGPoint(x: 0.4338, y: 0.8618), CGPoint(x: 0.4288, y: 0.8515),
        CGPoint(x: 0.4169, y: 0.8375), CGPoint(x: 0.4136, y: 0.8309), CGPoint(x: 0.3967, y: 0.8213),
        CGPoint(x: 0.3912, y: 0.811), CGPoint(x: 0.376, y: 0.7853), CGPoint(x: 0.3656, y: 0.7757),
        CGPoint(x: 0.3586, y: 0.7757), CGPoint(x: 0.3542, y: 0.8059), CGPoint(x: 0.3509, y: 0.8154),
        CGPoint(x: 0.3558, y: 0.836), CGPoint(x: 0.3477, y: 0.875), CGPoint(x: 0.3433, y: 0.8765),
        CGPoint(x: 0.3384, y: 0.8801)
    ],
    "UKR": [
        CGPoint(x: 0.5885, y: 0.6449), CGPoint(x: 0.6081, y: 0.6676), CGPoint(x: 0.612, y: 0.675),
        CGPoint(x: 0.6245, y: 0.6603), CGPoint(x: 0.6278, y: 0.6529), CGPoint(x: 0.6359, y: 0.636),
        CGPoint(x: 0.6441, y: 0.6301), CGPoint(x: 0.6539, y: 0.6228), CGPoint(x: 0.6681, y: 0.5846),
        CGPoint(x: 0.6708, y: 0.5625), CGPoint(x: 0.6724, y: 0.5456), CGPoint(x: 0.6703, y: 0.5346),
        CGPoint(x: 0.6659, y: 0.5324), CGPoint(x: 0.6534, y: 0.5316), CGPoint(x: 0.6316, y: 0.5375),
        CGPoint(x: 0.5885, y: 0.5522), CGPoint(x: 0.5787, y: 0.5559), CGPoint(x: 0.5678, y: 0.5647),
        CGPoint(x: 0.5656, y: 0.5846), CGPoint(x: 0.564, y: 0.5926), CGPoint(x: 0.5782, y: 0.6066),
        CGPoint(x: 0.5885, y: 0.639), CGPoint(x: 0.5885, y: 0.6449)
    ],
    "VEN": [
        CGPoint(x: 0.4152, y: 0.8096), CGPoint(x: 0.419, y: 0.8015), CGPoint(x: 0.4218, y: 0.7956),
        CGPoint(x: 0.419, y: 0.7868), CGPoint(x: 0.412, y: 0.7647), CGPoint(x: 0.3994, y: 0.7397),
        CGPoint(x: 0.4021, y: 0.7309), CGPoint(x: 0.4032, y: 0.7206), CGPoint(x: 0.4125, y: 0.7147),
        CGPoint(x: 0.4174, y: 0.7125), CGPoint(x: 0.4196, y: 0.7), CGPoint(x: 0.4185, y: 0.6963),
        CGPoint(x: 0.4098, y: 0.6941), CGPoint(x: 0.3983, y: 0.6978), CGPoint(x: 0.3967, y: 0.7029),
        CGPoint(x: 0.3842, y: 0.7147), CGPoint(x: 0.3776, y: 0.7103), CGPoint(x: 0.3738, y: 0.714),
        CGPoint(x: 0.3689, y: 0.7279), CGPoint(x: 0.3754, y: 0.7412), CGPoint(x: 0.3858, y: 0.75),
        CGPoint(x: 0.3983, y: 0.7669), CGPoint(x: 0.4071, y: 0.7897), CGPoint(x: 0.4087, y: 0.8015),
        CGPoint(x: 0.4152, y: 0.8096)
    ],
    "VIE": [
        CGPoint(x: 0.5024, y: 0.6368), CGPoint(x: 0.5024, y: 0.6316), CGPoint(x: 0.4991, y: 0.6287),
        CGPoint(x: 0.4883, y: 0.6243), CGPoint(x: 0.479, y: 0.625), CGPoint(x: 0.4697, y: 0.6221),
        CGPoint(x: 0.4632, y: 0.6235), CGPoint(x: 0.4523, y: 0.6243), CGPoint(x: 0.4452, y: 0.6375),
        CGPoint(x: 0.4403, y: 0.65), CGPoint(x: 0.4414, y: 0.6728), CGPoint(x: 0.4436, y: 0.6779),
        CGPoint(x: 0.4512, y: 0.6897), CGPoint(x: 0.4577, y: 0.6853), CGPoint(x: 0.4626, y: 0.6838),
        CGPoint(x: 0.4741, y: 0.6676), CGPoint(x: 0.4844, y: 0.6574), CGPoint(x: 0.4877, y: 0.6493),
        CGPoint(x: 0.497, y: 0.6368), CGPoint(x: 0.5024, y: 0.6368)
    ],
    "WAL": [
        CGPoint(x: 0.2272, y: 0.4706), CGPoint(x: 0.2299, y: 0.4838), CGPoint(x: 0.2152, y: 0.4904),
        CGPoint(x: 0.2212, y: 0.4993), CGPoint(x: 0.231, y: 0.5103), CGPoint(x: 0.2392, y: 0.511),
        CGPoint(x: 0.237, y: 0.5147), CGPoint(x: 0.2223, y: 0.5147), CGPoint(x: 0.2152, y: 0.5162),
        CGPoint(x: 0.2049, y: 0.5279), CGPoint(x: 0.1962, y: 0.5338), CGPoint(x: 0.2011, y: 0.5368),
        CGPoint(x: 0.2071, y: 0.5338), CGPoint(x: 0.2185, y: 0.5382), CGPoint(x: 0.2261, y: 0.5309),
        CGPoint(x: 0.237, y: 0.5346), CGPoint(x: 0.2534, y: 0.5368), CGPoint(x: 0.2485, y: 0.5162),
        CGPoint(x: 0.2556, y: 0.5015), CGPoint(x: 0.2599, y: 0.4978), CGPoint(x: 0.2599, y: 0.4868),
        CGPoint(x: 0.2452, y: 0.4787), CGPoint(x: 0.2425, y: 0.4706), CGPoint(x: 0.2419, y: 0.4632),
        CGPoint(x: 0.2272, y: 0.4706)
    ],
    "WAR": [
        CGPoint(x: 0.5368, y: 0.5074), CGPoint(x: 0.4932, y: 0.5309), CGPoint(x: 0.491, y: 0.5831),
        CGPoint(x: 0.4981, y: 0.5941), CGPoint(x: 0.5095, y: 0.5978), CGPoint(x: 0.5215, y: 0.5904),
        CGPoint(x: 0.5259, y: 0.5846), CGPoint(x: 0.54, y: 0.5904), CGPoint(x: 0.5547, y: 0.586),
        CGPoint(x: 0.5618, y: 0.5897), CGPoint(x: 0.5651, y: 0.5713), CGPoint(x: 0.5618, y: 0.55),
        CGPoint(x: 0.5591, y: 0.5426), CGPoint(x: 0.5553, y: 0.5279), CGPoint(x: 0.5444, y: 0.5169),
        CGPoint(x: 0.5368, y: 0.5074)
    ],
    "WES": [
        CGPoint(x: 0.261, y: 0.8375), CGPoint(x: 0.2572, y: 0.8449), CGPoint(x: 0.2338, y: 0.8463),
        CGPoint(x: 0.2011, y: 0.8522), CGPoint(x: 0.1754, y: 0.8743), CGPoint(x: 0.1607, y: 0.8816),
        CGPoint(x: 0.14, y: 0.875), CGPoint(x: 0.116, y: 0.8779), CGPoint(x: 0.115, y: 0.889),
        CGPoint(x: 0.1395, y: 0.9147), CGPoint(x: 0.1498, y: 0.9206), CGPoint(x: 0.1803, y: 0.9169),
        CGPoint(x: 0.1929, y: 0.9191), CGPoint(x: 0.2049, y: 0.9132), CGPoint(x: 0.2392, y: 0.9118),
        CGPoint(x: 0.2746, y: 0.9199), CGPoint(x: 0.2844, y: 0.9228), CGPoint(x: 0.3062, y: 0.9228),
        CGPoint(x: 0.3248, y: 0.9257), CGPoint(x: 0.34, y: 0.9015), CGPoint(x: 0.3335, y: 0.8735),
        CGPoint(x: 0.3335, y: 0.8485), CGPoint(x: 0.3182, y: 0.8404), CGPoint(x: 0.2708, y: 0.8368),
        CGPoint(x: 0.261, y: 0.8375)
    ],
    "YOR": [
        CGPoint(x: 0.2643, y: 0.4265), CGPoint(x: 0.2648, y: 0.4324), CGPoint(x: 0.2648, y: 0.439),
        CGPoint(x: 0.2615, y: 0.4662), CGPoint(x: 0.2626, y: 0.4985), CGPoint(x: 0.2768, y: 0.4904),
        CGPoint(x: 0.279, y: 0.4868), CGPoint(x: 0.2828, y: 0.4809), CGPoint(x: 0.2774, y: 0.4676),
        CGPoint(x: 0.2812, y: 0.4588), CGPoint(x: 0.2741, y: 0.4397), CGPoint(x: 0.2708, y: 0.4279),
        CGPoint(x: 0.2643, y: 0.4265)
    ],

    ]
}
