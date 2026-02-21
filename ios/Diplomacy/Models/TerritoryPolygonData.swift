import Foundation

// MARK: - Territory Polygon Boundaries
// High-fidelity polygons derived from the standard Diplomacy SVG map.
// Normalized coordinates (viewBox 0 0 1835 1360 → 0-1 range).
// Coast variants (BUL_EC, BUL_SC, SPA_NC, SPA_SC, STP_NC, STP_SC) use the parent polygon.
// 75 territories total.

enum TerritoryPolygonData {

    static let boundaries: [String: [CGPoint]] = [
    "ADR": [
        CGPoint(x: 0.6016, y: 0.9816), CGPoint(x: 0.6038, y: 0.9588), CGPoint(x: 0.6044, y: 0.9471),
        CGPoint(x: 0.5826, y: 0.9221), CGPoint(x: 0.5668, y: 0.9051), CGPoint(x: 0.5569, y: 0.8963),
        CGPoint(x: 0.5395, y: 0.8765), CGPoint(x: 0.5351, y: 0.8618), CGPoint(x: 0.5368, y: 0.8493),
        CGPoint(x: 0.5281, y: 0.8618), CGPoint(x: 0.5243, y: 0.8544), CGPoint(x: 0.5210, y: 0.8412),
        CGPoint(x: 0.5117, y: 0.8456), CGPoint(x: 0.5090, y: 0.8493), CGPoint(x: 0.5074, y: 0.8610),
        CGPoint(x: 0.5074, y: 0.8721), CGPoint(x: 0.5232, y: 0.8963), CGPoint(x: 0.5270, y: 0.9132),
        CGPoint(x: 0.5373, y: 0.9316), CGPoint(x: 0.5548, y: 0.9404), CGPoint(x: 0.5569, y: 0.9507),
        CGPoint(x: 0.5831, y: 0.9757), CGPoint(x: 0.5907, y: 0.9853), CGPoint(x: 0.6016, y: 0.9816)
    ],
    "AEG": [
        CGPoint(x: 0.6687, y: 0.9713), CGPoint(x: 0.6676, y: 0.9801), CGPoint(x: 0.6654, y: 0.9904),
        CGPoint(x: 0.6545, y: 0.9757), CGPoint(x: 0.6561, y: 1.0074), CGPoint(x: 0.6550, y: 1.0140),
        CGPoint(x: 0.6594, y: 1.0206), CGPoint(x: 0.6654, y: 1.0184), CGPoint(x: 0.6719, y: 1.0390),
        CGPoint(x: 0.6643, y: 1.0426), CGPoint(x: 0.6540, y: 1.0544), CGPoint(x: 0.6605, y: 1.0809),
        CGPoint(x: 0.6768, y: 1.1000), CGPoint(x: 0.6970, y: 1.1015), CGPoint(x: 0.7095, y: 1.1044),
        CGPoint(x: 0.7357, y: 1.0691), CGPoint(x: 0.7275, y: 1.0603), CGPoint(x: 0.7221, y: 1.0515),
        CGPoint(x: 0.7112, y: 1.0287), CGPoint(x: 0.7144, y: 1.0118), CGPoint(x: 0.7101, y: 0.9949),
        CGPoint(x: 0.6975, y: 0.9824), CGPoint(x: 0.7019, y: 0.9706), CGPoint(x: 0.6747, y: 0.9676),
        CGPoint(x: 0.6687, y: 0.9713)
    ],
    "ALB": [
        CGPoint(x: 0.6262, y: 0.9676), CGPoint(x: 0.6191, y: 0.9537), CGPoint(x: 0.6131, y: 0.9279),
        CGPoint(x: 0.6093, y: 0.9250), CGPoint(x: 0.6000, y: 0.9360), CGPoint(x: 0.6060, y: 0.9485),
        CGPoint(x: 0.6033, y: 0.9750), CGPoint(x: 0.6038, y: 0.9831), CGPoint(x: 0.6131, y: 0.9949),
        CGPoint(x: 0.6174, y: 0.9882), CGPoint(x: 0.6240, y: 0.9824), CGPoint(x: 0.6262, y: 0.9676)
    ],
    "ANK": [
        CGPoint(x: 0.7760, y: 1.0029), CGPoint(x: 0.7951, y: 0.9897), CGPoint(x: 0.8038, y: 0.9824),
        CGPoint(x: 0.8169, y: 0.9853), CGPoint(x: 0.8327, y: 0.9824), CGPoint(x: 0.8583, y: 0.9537),
        CGPoint(x: 0.8779, y: 0.9507), CGPoint(x: 0.8850, y: 0.9500), CGPoint(x: 0.8921, y: 0.9125),
        CGPoint(x: 0.8627, y: 0.9213), CGPoint(x: 0.8469, y: 0.9162), CGPoint(x: 0.8452, y: 0.9176),
        CGPoint(x: 0.8381, y: 0.9118), CGPoint(x: 0.8316, y: 0.9162), CGPoint(x: 0.8234, y: 0.9081),
        CGPoint(x: 0.8158, y: 0.9125), CGPoint(x: 0.7940, y: 0.9184), CGPoint(x: 0.7820, y: 0.9309),
        CGPoint(x: 0.7738, y: 0.9441), CGPoint(x: 0.7733, y: 0.9500), CGPoint(x: 0.7766, y: 0.9647),
        CGPoint(x: 0.7798, y: 0.9801), CGPoint(x: 0.7760, y: 1.0029)
    ],
    "APU": [
        CGPoint(x: 0.5297, y: 0.9235), CGPoint(x: 0.5232, y: 0.9353), CGPoint(x: 0.5281, y: 0.9434),
        CGPoint(x: 0.5401, y: 0.9559), CGPoint(x: 0.5493, y: 0.9706), CGPoint(x: 0.5520, y: 0.9809),
        CGPoint(x: 0.5624, y: 0.9890), CGPoint(x: 0.5673, y: 0.9794), CGPoint(x: 0.5700, y: 0.9779),
        CGPoint(x: 0.5733, y: 0.9816), CGPoint(x: 0.5826, y: 0.9897), CGPoint(x: 0.5880, y: 0.9912),
        CGPoint(x: 0.5869, y: 0.9824), CGPoint(x: 0.5749, y: 0.9699), CGPoint(x: 0.5564, y: 0.9515),
        CGPoint(x: 0.5542, y: 0.9463), CGPoint(x: 0.5537, y: 0.9412), CGPoint(x: 0.5493, y: 0.9404),
        CGPoint(x: 0.5422, y: 0.9375), CGPoint(x: 0.5297, y: 0.9235)
    ],
    "ARM": [
        CGPoint(x: 0.9106, y: 0.8956), CGPoint(x: 0.8926, y: 0.9118), CGPoint(x: 0.8943, y: 0.9125),
        CGPoint(x: 0.8932, y: 0.9581), CGPoint(x: 0.9003, y: 0.9691), CGPoint(x: 0.9030, y: 0.9831),
        CGPoint(x: 0.9308, y: 0.9831), CGPoint(x: 0.9373, y: 0.9838), CGPoint(x: 0.9428, y: 0.9838),
        CGPoint(x: 0.9946, y: 0.9912), CGPoint(x: 1.0054, y: 0.9919), CGPoint(x: 1.0213, y: 0.9890),
        CGPoint(x: 1.0501, y: 0.9610), CGPoint(x: 1.0659, y: 0.9412), CGPoint(x: 1.0561, y: 0.9390),
        CGPoint(x: 1.0289, y: 0.9206), CGPoint(x: 1.0185, y: 0.9132), CGPoint(x: 1.0125, y: 0.8978),
        CGPoint(x: 1.0044, y: 0.9088), CGPoint(x: 0.9837, y: 0.9272), CGPoint(x: 0.9629, y: 0.9206),
        CGPoint(x: 0.9553, y: 0.9206), CGPoint(x: 0.9335, y: 0.9191), CGPoint(x: 0.9106, y: 0.8956)
    ],
    "BAL": [
        CGPoint(x: 0.5777, y: 0.5243), CGPoint(x: 0.5760, y: 0.5397), CGPoint(x: 0.5673, y: 0.5728),
        CGPoint(x: 0.5591, y: 0.5735), CGPoint(x: 0.5411, y: 0.5912), CGPoint(x: 0.5357, y: 0.5912),
        CGPoint(x: 0.5302, y: 0.6007), CGPoint(x: 0.4997, y: 0.5912), CGPoint(x: 0.5035, y: 0.6051),
        CGPoint(x: 0.5068, y: 0.6221), CGPoint(x: 0.5134, y: 0.6213), CGPoint(x: 0.5270, y: 0.6147),
        CGPoint(x: 0.5362, y: 0.6110), CGPoint(x: 0.5379, y: 0.6110), CGPoint(x: 0.5488, y: 0.6250),
        CGPoint(x: 0.5755, y: 0.6147), CGPoint(x: 0.6033, y: 0.6176), CGPoint(x: 0.6109, y: 0.6103),
        CGPoint(x: 0.6174, y: 0.6000), CGPoint(x: 0.6207, y: 0.6000), CGPoint(x: 0.6234, y: 0.5890),
        CGPoint(x: 0.6278, y: 0.5404), CGPoint(x: 0.6158, y: 0.5397), CGPoint(x: 0.5777, y: 0.5243)
    ],
    "BAR": [
        CGPoint(x: 0.6420, y: 0.1287), CGPoint(x: 0.6414, y: 0.1919), CGPoint(x: 0.6534, y: 0.1926),
        CGPoint(x: 0.6638, y: 0.1926), CGPoint(x: 0.6703, y: 0.2125), CGPoint(x: 0.6943, y: 0.2213),
        CGPoint(x: 0.7324, y: 0.2309), CGPoint(x: 0.7591, y: 0.2846), CGPoint(x: 0.7155, y: 0.2853),
        CGPoint(x: 0.7166, y: 0.2985), CGPoint(x: 0.7357, y: 0.3397), CGPoint(x: 0.7597, y: 0.3456),
        CGPoint(x: 0.7471, y: 0.3162), CGPoint(x: 0.7886, y: 0.3243), CGPoint(x: 0.7700, y: 0.3103),
        CGPoint(x: 0.7891, y: 0.2699), CGPoint(x: 0.7717, y: 0.2110), CGPoint(x: 0.8049, y: 0.2419),
        CGPoint(x: 0.8283, y: 0.1868), CGPoint(x: 0.8349, y: 0.1985), CGPoint(x: 0.8414, y: 0.1846),
        CGPoint(x: 0.8594, y: 0.1500), CGPoint(x: 0.8703, y: 0.1544), CGPoint(x: 0.8621, y: 0.1294),
        CGPoint(x: 0.6420, y: 0.1287)
    ],
    "BEL": [
        CGPoint(x: 0.3896, y: 0.6846), CGPoint(x: 0.4071, y: 0.6985), CGPoint(x: 0.4234, y: 0.7125),
        CGPoint(x: 0.4381, y: 0.7206), CGPoint(x: 0.4398, y: 0.7118), CGPoint(x: 0.4338, y: 0.6912),
        CGPoint(x: 0.4322, y: 0.6809), CGPoint(x: 0.4262, y: 0.6772), CGPoint(x: 0.4223, y: 0.6750),
        CGPoint(x: 0.4147, y: 0.6676), CGPoint(x: 0.4022, y: 0.6713), CGPoint(x: 0.3935, y: 0.6743),
        CGPoint(x: 0.3896, y: 0.6846)
    ],
    "BER": [
        CGPoint(x: 0.5117, y: 0.6897), CGPoint(x: 0.5281, y: 0.6831), CGPoint(x: 0.5455, y: 0.6787),
        CGPoint(x: 0.5542, y: 0.6713), CGPoint(x: 0.5537, y: 0.6610), CGPoint(x: 0.5504, y: 0.6500),
        CGPoint(x: 0.5488, y: 0.6272), CGPoint(x: 0.5395, y: 0.6228), CGPoint(x: 0.5373, y: 0.6176),
        CGPoint(x: 0.5390, y: 0.6147), CGPoint(x: 0.5368, y: 0.6125), CGPoint(x: 0.5226, y: 0.6184),
        CGPoint(x: 0.5161, y: 0.6213), CGPoint(x: 0.5139, y: 0.6382), CGPoint(x: 0.5101, y: 0.6706),
        CGPoint(x: 0.5117, y: 0.6897)
    ],
    "BLA": [
        CGPoint(x: 0.8556, y: 0.7588), CGPoint(x: 0.8082, y: 0.7993), CGPoint(x: 0.8153, y: 0.8221),
        CGPoint(x: 0.8191, y: 0.8309), CGPoint(x: 0.8038, y: 0.8485), CGPoint(x: 0.7913, y: 0.8360),
        CGPoint(x: 0.7858, y: 0.8176), CGPoint(x: 0.7722, y: 0.8125), CGPoint(x: 0.7689, y: 0.7978),
        CGPoint(x: 0.7444, y: 0.8103), CGPoint(x: 0.7417, y: 0.8368), CGPoint(x: 0.7297, y: 0.8897),
        CGPoint(x: 0.7204, y: 0.9162), CGPoint(x: 0.7384, y: 0.9375), CGPoint(x: 0.7733, y: 0.9412),
        CGPoint(x: 0.8180, y: 0.9096), CGPoint(x: 0.8354, y: 0.9125), CGPoint(x: 0.8463, y: 0.9132),
        CGPoint(x: 0.8839, y: 0.9132), CGPoint(x: 0.9046, y: 0.8610), CGPoint(x: 0.8572, y: 0.8331),
        CGPoint(x: 0.8338, y: 0.8213), CGPoint(x: 0.8431, y: 0.8074), CGPoint(x: 0.8414, y: 0.7779),
        CGPoint(x: 0.8556, y: 0.7588)
    ],
    "BOH": [
        CGPoint(x: 0.5891, y: 0.7471), CGPoint(x: 0.5880, y: 0.7331), CGPoint(x: 0.5902, y: 0.7331),
        CGPoint(x: 0.5858, y: 0.7316), CGPoint(x: 0.5793, y: 0.7279), CGPoint(x: 0.5700, y: 0.7235),
        CGPoint(x: 0.5493, y: 0.7066), CGPoint(x: 0.5248, y: 0.7162), CGPoint(x: 0.5177, y: 0.7228),
        CGPoint(x: 0.5193, y: 0.7331), CGPoint(x: 0.5324, y: 0.7551), CGPoint(x: 0.5373, y: 0.7647),
        CGPoint(x: 0.5444, y: 0.7654), CGPoint(x: 0.5477, y: 0.7654), CGPoint(x: 0.5515, y: 0.7581),
        CGPoint(x: 0.5646, y: 0.7441), CGPoint(x: 0.5700, y: 0.7456), CGPoint(x: 0.5777, y: 0.7441),
        CGPoint(x: 0.5847, y: 0.7471), CGPoint(x: 0.5891, y: 0.7471)
    ],
    "BOT": [
        CGPoint(x: 0.5766, y: 0.5088), CGPoint(x: 0.5798, y: 0.5213), CGPoint(x: 0.6153, y: 0.5368),
        CGPoint(x: 0.6311, y: 0.5346), CGPoint(x: 0.6496, y: 0.5478), CGPoint(x: 0.6550, y: 0.5169),
        CGPoint(x: 0.6463, y: 0.4949), CGPoint(x: 0.6812, y: 0.4824), CGPoint(x: 0.6965, y: 0.4684),
        CGPoint(x: 0.7074, y: 0.4662), CGPoint(x: 0.6872, y: 0.4537), CGPoint(x: 0.6583, y: 0.4676),
        CGPoint(x: 0.6376, y: 0.4669), CGPoint(x: 0.6289, y: 0.4618), CGPoint(x: 0.6213, y: 0.4471),
        CGPoint(x: 0.6202, y: 0.4066), CGPoint(x: 0.6354, y: 0.3735), CGPoint(x: 0.6523, y: 0.3412),
        CGPoint(x: 0.6316, y: 0.3257), CGPoint(x: 0.6229, y: 0.3632), CGPoint(x: 0.6011, y: 0.3934),
        CGPoint(x: 0.5880, y: 0.4257), CGPoint(x: 0.5940, y: 0.4625), CGPoint(x: 0.5967, y: 0.4919),
        CGPoint(x: 0.5766, y: 0.5088)
    ],
    "BRE": [
        CGPoint(x: 0.3439, y: 0.6882), CGPoint(x: 0.3450, y: 0.7000), CGPoint(x: 0.3439, y: 0.7103),
        CGPoint(x: 0.3384, y: 0.7140), CGPoint(x: 0.3275, y: 0.7081), CGPoint(x: 0.3226, y: 0.7029),
        CGPoint(x: 0.3046, y: 0.7044), CGPoint(x: 0.3025, y: 0.7096), CGPoint(x: 0.2997, y: 0.7154),
        CGPoint(x: 0.3090, y: 0.7221), CGPoint(x: 0.3221, y: 0.7368), CGPoint(x: 0.3264, y: 0.7493),
        CGPoint(x: 0.3264, y: 0.7581), CGPoint(x: 0.3324, y: 0.7735), CGPoint(x: 0.3548, y: 0.7816),
        CGPoint(x: 0.3575, y: 0.7544), CGPoint(x: 0.3575, y: 0.7419), CGPoint(x: 0.3569, y: 0.7346),
        CGPoint(x: 0.3608, y: 0.7044), CGPoint(x: 0.3493, y: 0.6904), CGPoint(x: 0.3439, y: 0.6882),
        CGPoint(x: 0.3014, y: 0.7118), CGPoint(x: 0.3008, y: 0.7118), CGPoint(x: 0.3014, y: 0.7118)
    ],
    "BUD": [
        CGPoint(x: 0.6109, y: 0.7566), CGPoint(x: 0.6104, y: 0.7610), CGPoint(x: 0.6044, y: 0.7640),
        CGPoint(x: 0.5913, y: 0.7860), CGPoint(x: 0.5826, y: 0.7941), CGPoint(x: 0.5755, y: 0.8037),
        CGPoint(x: 0.5711, y: 0.8184), CGPoint(x: 0.5793, y: 0.8375), CGPoint(x: 0.5880, y: 0.8441),
        CGPoint(x: 0.6011, y: 0.8625), CGPoint(x: 0.6054, y: 0.8610), CGPoint(x: 0.6169, y: 0.8596),
        CGPoint(x: 0.6234, y: 0.8632), CGPoint(x: 0.6332, y: 0.8640), CGPoint(x: 0.6490, y: 0.8551),
        CGPoint(x: 0.6572, y: 0.8500), CGPoint(x: 0.6856, y: 0.8404), CGPoint(x: 0.6948, y: 0.8257),
        CGPoint(x: 0.6828, y: 0.8051), CGPoint(x: 0.6725, y: 0.7831), CGPoint(x: 0.6654, y: 0.7765),
        CGPoint(x: 0.6523, y: 0.7596), CGPoint(x: 0.6289, y: 0.7507), CGPoint(x: 0.6109, y: 0.7566)
    ],
    "BUL": [
        CGPoint(x: 0.6474, y: 0.8816), CGPoint(x: 0.6469, y: 0.8941), CGPoint(x: 0.6518, y: 0.9096),
        CGPoint(x: 0.6485, y: 0.9228), CGPoint(x: 0.6480, y: 0.9493), CGPoint(x: 0.6583, y: 0.9515),
        CGPoint(x: 0.6670, y: 0.9471), CGPoint(x: 0.6807, y: 0.9537), CGPoint(x: 0.6812, y: 0.9610),
        CGPoint(x: 0.6812, y: 0.9640), CGPoint(x: 0.6916, y: 0.9640), CGPoint(x: 0.6970, y: 0.9640),
        CGPoint(x: 0.6992, y: 0.9603), CGPoint(x: 0.7046, y: 0.9338), CGPoint(x: 0.7237, y: 0.9279),
        CGPoint(x: 0.7193, y: 0.9176), CGPoint(x: 0.7204, y: 0.9103), CGPoint(x: 0.7226, y: 0.8956),
        CGPoint(x: 0.7292, y: 0.8868), CGPoint(x: 0.6997, y: 0.8853), CGPoint(x: 0.6883, y: 0.8904),
        CGPoint(x: 0.6768, y: 0.8912), CGPoint(x: 0.6698, y: 0.8904), CGPoint(x: 0.6545, y: 0.8882),
        CGPoint(x: 0.6474, y: 0.8816)
    ],
    "BUR": [
        CGPoint(x: 0.4213, y: 0.7169), CGPoint(x: 0.4093, y: 0.7463), CGPoint(x: 0.4044, y: 0.7507),
        CGPoint(x: 0.3995, y: 0.7559), CGPoint(x: 0.3951, y: 0.7596), CGPoint(x: 0.3907, y: 0.7654),
        CGPoint(x: 0.3853, y: 0.7691), CGPoint(x: 0.3820, y: 0.7824), CGPoint(x: 0.3722, y: 0.7985),
        CGPoint(x: 0.3749, y: 0.8059), CGPoint(x: 0.3826, y: 0.8110), CGPoint(x: 0.3815, y: 0.8221),
        CGPoint(x: 0.3946, y: 0.8368), CGPoint(x: 0.4016, y: 0.8176), CGPoint(x: 0.4033, y: 0.8074),
        CGPoint(x: 0.4082, y: 0.8074), CGPoint(x: 0.4163, y: 0.8096), CGPoint(x: 0.4207, y: 0.8088),
        CGPoint(x: 0.4278, y: 0.7985), CGPoint(x: 0.4420, y: 0.7779), CGPoint(x: 0.4441, y: 0.7676),
        CGPoint(x: 0.4458, y: 0.7603), CGPoint(x: 0.4403, y: 0.7456), CGPoint(x: 0.4371, y: 0.7250),
        CGPoint(x: 0.4213, y: 0.7169)
    ],
    "CLY": [
        CGPoint(x: 0.3401, y: 0.5007), CGPoint(x: 0.3439, y: 0.5059), CGPoint(x: 0.3586, y: 0.5103),
        CGPoint(x: 0.3602, y: 0.4926), CGPoint(x: 0.3646, y: 0.4684), CGPoint(x: 0.3738, y: 0.4559),
        CGPoint(x: 0.3662, y: 0.4544), CGPoint(x: 0.3602, y: 0.4618), CGPoint(x: 0.3515, y: 0.4699),
        CGPoint(x: 0.3439, y: 0.4699), CGPoint(x: 0.3466, y: 0.4838), CGPoint(x: 0.3401, y: 0.5007)
    ],
    "CON": [
        CGPoint(x: 0.7253, y: 0.9316), CGPoint(x: 0.7035, y: 0.9596), CGPoint(x: 0.7101, y: 0.9684),
        CGPoint(x: 0.7030, y: 0.9794), CGPoint(x: 0.7068, y: 0.9735), CGPoint(x: 0.7286, y: 0.9544),
        CGPoint(x: 0.7302, y: 0.9426), CGPoint(x: 0.7706, y: 0.9441), CGPoint(x: 0.7493, y: 0.9500),
        CGPoint(x: 0.7433, y: 0.9551), CGPoint(x: 0.7520, y: 0.9603), CGPoint(x: 0.7395, y: 0.9669),
        CGPoint(x: 0.7243, y: 0.9750), CGPoint(x: 0.7019, y: 0.9919), CGPoint(x: 0.7123, y: 0.9993),
        CGPoint(x: 0.7188, y: 0.9963), CGPoint(x: 0.7253, y: 1.0000), CGPoint(x: 0.7455, y: 1.0007),
        CGPoint(x: 0.7629, y: 1.0007), CGPoint(x: 0.7733, y: 1.0022), CGPoint(x: 0.7749, y: 0.9662),
        CGPoint(x: 0.7717, y: 0.9537), CGPoint(x: 0.7335, y: 0.9522), CGPoint(x: 0.7330, y: 0.9522),
        CGPoint(x: 0.7335, y: 0.9522)
    ],
    "DEN": [
        CGPoint(x: 0.5117, y: 0.5265), CGPoint(x: 0.4997, y: 0.5353), CGPoint(x: 0.4905, y: 0.5397),
        CGPoint(x: 0.4845, y: 0.5713), CGPoint(x: 0.4872, y: 0.5853), CGPoint(x: 0.4992, y: 0.5868),
        CGPoint(x: 0.5014, y: 0.5765), CGPoint(x: 0.5068, y: 0.5662), CGPoint(x: 0.5101, y: 0.5632),
        CGPoint(x: 0.5139, y: 0.5610), CGPoint(x: 0.5123, y: 0.5397), CGPoint(x: 0.5117, y: 0.5265),
        CGPoint(x: 0.5155, y: 0.5779), CGPoint(x: 0.5226, y: 0.5919), CGPoint(x: 0.5270, y: 0.5978),
        CGPoint(x: 0.5308, y: 0.5860), CGPoint(x: 0.5297, y: 0.5794), CGPoint(x: 0.5253, y: 0.5699),
        CGPoint(x: 0.5221, y: 0.5699), CGPoint(x: 0.5155, y: 0.5779), CGPoint(x: 0.5144, y: 0.5971),
        CGPoint(x: 0.5139, y: 0.6000), CGPoint(x: 0.5172, y: 0.5985), CGPoint(x: 0.5144, y: 0.5971)
    ],
    "EAS": [
        CGPoint(x: 0.7106, y: 1.1074), CGPoint(x: 0.6883, y: 1.1147), CGPoint(x: 0.6687, y: 1.1096),
        CGPoint(x: 0.6687, y: 1.1228), CGPoint(x: 0.8621, y: 1.1140), CGPoint(x: 0.8589, y: 1.0743),
        CGPoint(x: 0.8561, y: 1.0750), CGPoint(x: 0.8540, y: 1.0529), CGPoint(x: 0.8567, y: 1.0360),
        CGPoint(x: 0.8360, y: 1.0463), CGPoint(x: 0.8093, y: 1.0691), CGPoint(x: 0.7995, y: 1.0640),
        CGPoint(x: 0.7793, y: 1.0551), CGPoint(x: 0.7646, y: 1.0765), CGPoint(x: 0.7548, y: 1.0728),
        CGPoint(x: 0.7455, y: 1.0654), CGPoint(x: 0.7357, y: 1.0801), CGPoint(x: 0.7106, y: 1.1074),
        CGPoint(x: 0.8322, y: 1.0838), CGPoint(x: 0.8316, y: 1.0919), CGPoint(x: 0.8196, y: 1.1044),
        CGPoint(x: 0.8038, y: 1.0963), CGPoint(x: 0.8104, y: 1.0897), CGPoint(x: 0.8267, y: 1.0809),
        CGPoint(x: 0.8371, y: 1.0735)
    ],
    "EDI": [
        CGPoint(x: 0.3760, y: 0.4566), CGPoint(x: 0.3668, y: 0.4691), CGPoint(x: 0.3629, y: 0.4875),
        CGPoint(x: 0.3602, y: 0.5140), CGPoint(x: 0.3608, y: 0.5316), CGPoint(x: 0.3689, y: 0.5485),
        CGPoint(x: 0.3771, y: 0.5493), CGPoint(x: 0.3793, y: 0.5390), CGPoint(x: 0.3744, y: 0.5154),
        CGPoint(x: 0.3853, y: 0.4978), CGPoint(x: 0.3891, y: 0.4890), CGPoint(x: 0.3760, y: 0.4794),
        CGPoint(x: 0.3689, y: 0.4787), CGPoint(x: 0.3722, y: 0.4721), CGPoint(x: 0.3815, y: 0.4640),
        CGPoint(x: 0.3793, y: 0.4574), CGPoint(x: 0.3760, y: 0.4566)
    ],
    "ENG": [
        CGPoint(x: 0.2714, y: 0.6779), CGPoint(x: 0.2801, y: 0.6853), CGPoint(x: 0.3041, y: 0.7015),
        CGPoint(x: 0.3112, y: 0.7000), CGPoint(x: 0.3177, y: 0.7015), CGPoint(x: 0.3281, y: 0.7074),
        CGPoint(x: 0.3324, y: 0.7088), CGPoint(x: 0.3433, y: 0.7154), CGPoint(x: 0.3428, y: 0.6882),
        CGPoint(x: 0.3504, y: 0.6882), CGPoint(x: 0.3531, y: 0.6978), CGPoint(x: 0.3717, y: 0.6963),
        CGPoint(x: 0.3815, y: 0.6934), CGPoint(x: 0.3929, y: 0.6728), CGPoint(x: 0.3847, y: 0.6684),
        CGPoint(x: 0.3777, y: 0.6699), CGPoint(x: 0.3657, y: 0.6676), CGPoint(x: 0.3433, y: 0.6618),
        CGPoint(x: 0.3341, y: 0.6574), CGPoint(x: 0.3259, y: 0.6640), CGPoint(x: 0.3155, y: 0.6596),
        CGPoint(x: 0.3084, y: 0.6632), CGPoint(x: 0.3019, y: 0.6618), CGPoint(x: 0.2714, y: 0.6779)
    ],
    "FIN": [
        CGPoint(x: 0.6436, y: 0.3235), CGPoint(x: 0.6480, y: 0.3515), CGPoint(x: 0.6403, y: 0.3676),
        CGPoint(x: 0.6213, y: 0.4066), CGPoint(x: 0.6229, y: 0.4206), CGPoint(x: 0.6251, y: 0.4309),
        CGPoint(x: 0.6245, y: 0.4574), CGPoint(x: 0.6338, y: 0.4640), CGPoint(x: 0.6376, y: 0.4654),
        CGPoint(x: 0.6567, y: 0.4669), CGPoint(x: 0.6877, y: 0.4515), CGPoint(x: 0.6948, y: 0.4404),
        CGPoint(x: 0.7019, y: 0.4037), CGPoint(x: 0.6954, y: 0.3551), CGPoint(x: 0.6839, y: 0.3140),
        CGPoint(x: 0.6796, y: 0.2735), CGPoint(x: 0.6714, y: 0.2449), CGPoint(x: 0.6670, y: 0.2419),
        CGPoint(x: 0.6534, y: 0.2199), CGPoint(x: 0.6425, y: 0.2441), CGPoint(x: 0.6262, y: 0.2412),
        CGPoint(x: 0.6163, y: 0.2404), CGPoint(x: 0.6316, y: 0.2632), CGPoint(x: 0.6414, y: 0.3015),
        CGPoint(x: 0.6436, y: 0.3235)
    ],
    "GAL": [
        CGPoint(x: 0.5902, y: 0.7331), CGPoint(x: 0.5913, y: 0.7463), CGPoint(x: 0.6027, y: 0.7485),
        CGPoint(x: 0.6104, y: 0.7537), CGPoint(x: 0.6163, y: 0.7515), CGPoint(x: 0.6294, y: 0.7485),
        CGPoint(x: 0.6398, y: 0.7537), CGPoint(x: 0.6545, y: 0.7581), CGPoint(x: 0.6670, y: 0.7750),
        CGPoint(x: 0.6747, y: 0.7831), CGPoint(x: 0.6823, y: 0.7963), CGPoint(x: 0.6916, y: 0.7838),
        CGPoint(x: 0.6916, y: 0.7662), CGPoint(x: 0.6834, y: 0.7360), CGPoint(x: 0.6725, y: 0.7265),
        CGPoint(x: 0.6627, y: 0.7162), CGPoint(x: 0.6501, y: 0.7213), CGPoint(x: 0.6398, y: 0.7169),
        CGPoint(x: 0.6338, y: 0.7140), CGPoint(x: 0.6294, y: 0.7191), CGPoint(x: 0.6213, y: 0.7265),
        CGPoint(x: 0.6125, y: 0.7272), CGPoint(x: 0.6054, y: 0.7257), CGPoint(x: 0.5995, y: 0.7309),
        CGPoint(x: 0.5902, y: 0.7331)
    ],
    "GAS": [
        CGPoint(x: 0.3330, y: 0.7779), CGPoint(x: 0.3330, y: 0.7934), CGPoint(x: 0.3346, y: 0.7985),
        CGPoint(x: 0.3319, y: 0.7971), CGPoint(x: 0.3275, y: 0.8103), CGPoint(x: 0.3275, y: 0.8162),
        CGPoint(x: 0.3210, y: 0.8338), CGPoint(x: 0.3161, y: 0.8419), CGPoint(x: 0.3139, y: 0.8463),
        CGPoint(x: 0.3226, y: 0.8588), CGPoint(x: 0.3379, y: 0.8699), CGPoint(x: 0.3450, y: 0.8713),
        CGPoint(x: 0.3526, y: 0.8757), CGPoint(x: 0.3619, y: 0.8581), CGPoint(x: 0.3684, y: 0.8449),
        CGPoint(x: 0.3787, y: 0.8419), CGPoint(x: 0.3842, y: 0.8360), CGPoint(x: 0.3798, y: 0.8250),
        CGPoint(x: 0.3815, y: 0.8118), CGPoint(x: 0.3728, y: 0.8074), CGPoint(x: 0.3689, y: 0.7993),
        CGPoint(x: 0.3613, y: 0.7941), CGPoint(x: 0.3542, y: 0.7846), CGPoint(x: 0.3330, y: 0.7779)
    ],
    "GOL": [
        CGPoint(x: 0.3673, y: 0.9610), CGPoint(x: 0.4142, y: 0.9588), CGPoint(x: 0.4409, y: 0.9699),
        CGPoint(x: 0.4403, y: 0.9485), CGPoint(x: 0.4556, y: 0.9449), CGPoint(x: 0.4529, y: 0.9110),
        CGPoint(x: 0.4654, y: 0.8978), CGPoint(x: 0.4774, y: 0.8993), CGPoint(x: 0.4757, y: 0.8809),
        CGPoint(x: 0.4589, y: 0.8654), CGPoint(x: 0.4480, y: 0.8743), CGPoint(x: 0.4218, y: 0.8897),
        CGPoint(x: 0.4076, y: 0.8772), CGPoint(x: 0.4000, y: 0.8757), CGPoint(x: 0.3826, y: 0.8721),
        CGPoint(x: 0.3706, y: 0.9059), CGPoint(x: 0.3368, y: 0.9199), CGPoint(x: 0.3297, y: 0.9279),
        CGPoint(x: 0.3270, y: 0.9316), CGPoint(x: 0.3177, y: 0.9478), CGPoint(x: 0.3139, y: 0.9544),
        CGPoint(x: 0.3215, y: 0.9706), CGPoint(x: 0.3499, y: 0.9632), CGPoint(x: 0.3559, y: 0.9566),
        CGPoint(x: 0.3673, y: 0.9610)
    ],
    "GRE": [
        CGPoint(x: 0.6294, y: 1.0184), CGPoint(x: 0.6256, y: 1.0228), CGPoint(x: 0.6518, y: 1.0316),
        CGPoint(x: 0.6540, y: 1.0426), CGPoint(x: 0.6354, y: 1.0390), CGPoint(x: 0.6311, y: 1.0478),
        CGPoint(x: 0.6409, y: 1.0691), CGPoint(x: 0.6534, y: 1.0743), CGPoint(x: 0.6545, y: 1.0529),
        CGPoint(x: 0.6599, y: 1.0456), CGPoint(x: 0.6708, y: 1.0397), CGPoint(x: 0.6534, y: 1.0206),
        CGPoint(x: 0.6605, y: 1.0066), CGPoint(x: 0.6545, y: 0.9750), CGPoint(x: 0.6627, y: 0.9875),
        CGPoint(x: 0.6659, y: 0.9787), CGPoint(x: 0.6681, y: 0.9721), CGPoint(x: 0.6747, y: 0.9500),
        CGPoint(x: 0.6469, y: 0.9618), CGPoint(x: 0.6300, y: 0.9750), CGPoint(x: 0.6202, y: 0.9919),
        CGPoint(x: 0.6213, y: 1.0162), CGPoint(x: 0.6583, y: 1.0162), CGPoint(x: 0.6659, y: 1.0213),
        CGPoint(x: 0.6583, y: 1.0162)
    ],
    "HEL": [
        CGPoint(x: 0.4452, y: 0.6235), CGPoint(x: 0.4627, y: 0.6235), CGPoint(x: 0.4714, y: 0.6176),
        CGPoint(x: 0.4817, y: 0.6228), CGPoint(x: 0.4850, y: 0.6118), CGPoint(x: 0.4850, y: 0.6022),
        CGPoint(x: 0.4845, y: 0.5934), CGPoint(x: 0.4856, y: 0.5809), CGPoint(x: 0.4839, y: 0.5735),
        CGPoint(x: 0.4834, y: 0.5654), CGPoint(x: 0.4725, y: 0.5654), CGPoint(x: 0.4545, y: 0.5794),
        CGPoint(x: 0.4463, y: 0.6118), CGPoint(x: 0.4452, y: 0.6235)
    ],
    "HOL": [
        CGPoint(x: 0.4185, y: 0.6662), CGPoint(x: 0.4354, y: 0.6779), CGPoint(x: 0.4381, y: 0.6934),
        CGPoint(x: 0.4392, y: 0.6934), CGPoint(x: 0.4441, y: 0.6794), CGPoint(x: 0.4469, y: 0.6662),
        CGPoint(x: 0.4572, y: 0.6559), CGPoint(x: 0.4594, y: 0.6463), CGPoint(x: 0.4632, y: 0.6250),
        CGPoint(x: 0.4485, y: 0.6243), CGPoint(x: 0.4338, y: 0.6368), CGPoint(x: 0.4251, y: 0.6618),
        CGPoint(x: 0.4185, y: 0.6662)
    ],
    "ION": [
        CGPoint(x: 0.5689, y: 0.9787), CGPoint(x: 0.5613, y: 0.9971), CGPoint(x: 0.5684, y: 1.0184),
        CGPoint(x: 0.5602, y: 1.0294), CGPoint(x: 0.5455, y: 1.0360), CGPoint(x: 0.5411, y: 1.0426),
        CGPoint(x: 0.5373, y: 1.0699), CGPoint(x: 0.5199, y: 1.0647), CGPoint(x: 0.5008, y: 1.0507),
        CGPoint(x: 0.4894, y: 1.0485), CGPoint(x: 0.4659, y: 1.0809), CGPoint(x: 0.4730, y: 1.1228),
        CGPoint(x: 0.6670, y: 1.1096), CGPoint(x: 0.6480, y: 1.0846), CGPoint(x: 0.6381, y: 1.0743),
        CGPoint(x: 0.6349, y: 1.0581), CGPoint(x: 0.6349, y: 1.0375), CGPoint(x: 0.6556, y: 1.0412),
        CGPoint(x: 0.6474, y: 1.0309), CGPoint(x: 0.6294, y: 1.0338), CGPoint(x: 0.6218, y: 1.0184),
        CGPoint(x: 0.6136, y: 1.0007), CGPoint(x: 0.5907, y: 0.9897), CGPoint(x: 0.5820, y: 0.9912),
        CGPoint(x: 0.5689, y: 0.9787)
    ],
    "IRI": [
        CGPoint(x: 0.2670, y: 0.6029), CGPoint(x: 0.2463, y: 0.6316), CGPoint(x: 0.2589, y: 0.6669),
        CGPoint(x: 0.2687, y: 0.6757), CGPoint(x: 0.2807, y: 0.6699), CGPoint(x: 0.2992, y: 0.6596),
        CGPoint(x: 0.3106, y: 0.6515), CGPoint(x: 0.3177, y: 0.6456), CGPoint(x: 0.3204, y: 0.6404),
        CGPoint(x: 0.3281, y: 0.6382), CGPoint(x: 0.3346, y: 0.6397), CGPoint(x: 0.3439, y: 0.6375),
        CGPoint(x: 0.3270, y: 0.6250), CGPoint(x: 0.3199, y: 0.6162), CGPoint(x: 0.3368, y: 0.6015),
        CGPoint(x: 0.3324, y: 0.5956), CGPoint(x: 0.3515, y: 0.5897), CGPoint(x: 0.3537, y: 0.5868),
        CGPoint(x: 0.3531, y: 0.5632), CGPoint(x: 0.3248, y: 0.5581), CGPoint(x: 0.3177, y: 0.5875),
        CGPoint(x: 0.3090, y: 0.5985), CGPoint(x: 0.2981, y: 0.5985), CGPoint(x: 0.2670, y: 0.6029)
    ],
    "KIE": [
        CGPoint(x: 0.4485, y: 0.6735), CGPoint(x: 0.4752, y: 0.6897), CGPoint(x: 0.4839, y: 0.7015),
        CGPoint(x: 0.4877, y: 0.7059), CGPoint(x: 0.4937, y: 0.7015), CGPoint(x: 0.5052, y: 0.6949),
        CGPoint(x: 0.5084, y: 0.6904), CGPoint(x: 0.5079, y: 0.6750), CGPoint(x: 0.5084, y: 0.6676),
        CGPoint(x: 0.5101, y: 0.6515), CGPoint(x: 0.5134, y: 0.6235), CGPoint(x: 0.5046, y: 0.6235),
        CGPoint(x: 0.5084, y: 0.6147), CGPoint(x: 0.5030, y: 0.6066), CGPoint(x: 0.4986, y: 0.5904),
        CGPoint(x: 0.4905, y: 0.5904), CGPoint(x: 0.4866, y: 0.5912), CGPoint(x: 0.4866, y: 0.6051),
        CGPoint(x: 0.4828, y: 0.6235), CGPoint(x: 0.4681, y: 0.6213), CGPoint(x: 0.4665, y: 0.6309),
        CGPoint(x: 0.4627, y: 0.6471), CGPoint(x: 0.4605, y: 0.6566), CGPoint(x: 0.4485, y: 0.6735)
    ],
    "LON": [
        CGPoint(x: 0.3902, y: 0.6625), CGPoint(x: 0.3826, y: 0.6566), CGPoint(x: 0.3880, y: 0.6471),
        CGPoint(x: 0.4011, y: 0.6294), CGPoint(x: 0.4005, y: 0.6243), CGPoint(x: 0.3842, y: 0.6176),
        CGPoint(x: 0.3782, y: 0.6213), CGPoint(x: 0.3700, y: 0.6257), CGPoint(x: 0.3646, y: 0.6272),
        CGPoint(x: 0.3569, y: 0.6434), CGPoint(x: 0.3619, y: 0.6603), CGPoint(x: 0.3646, y: 0.6654),
        CGPoint(x: 0.3706, y: 0.6676), CGPoint(x: 0.3902, y: 0.6625)
    ],
    "LVN": [
        CGPoint(x: 0.6485, y: 0.4912), CGPoint(x: 0.6480, y: 0.5059), CGPoint(x: 0.6572, y: 0.5228),
        CGPoint(x: 0.6561, y: 0.5426), CGPoint(x: 0.6496, y: 0.5493), CGPoint(x: 0.6343, y: 0.5331),
        CGPoint(x: 0.6240, y: 0.5640), CGPoint(x: 0.6245, y: 0.5735), CGPoint(x: 0.6305, y: 0.5801),
        CGPoint(x: 0.6458, y: 0.5993), CGPoint(x: 0.6474, y: 0.6206), CGPoint(x: 0.6458, y: 0.6301),
        CGPoint(x: 0.6632, y: 0.6515), CGPoint(x: 0.6774, y: 0.6353), CGPoint(x: 0.6817, y: 0.6287),
        CGPoint(x: 0.6910, y: 0.6235), CGPoint(x: 0.6932, y: 0.5890), CGPoint(x: 0.6954, y: 0.5779),
        CGPoint(x: 0.6943, y: 0.5669), CGPoint(x: 0.6965, y: 0.5309), CGPoint(x: 0.6866, y: 0.5154),
        CGPoint(x: 0.6790, y: 0.5015), CGPoint(x: 0.6670, y: 0.5015), CGPoint(x: 0.6485, y: 0.4912)
    ],
    "LVP": [
        CGPoint(x: 0.3390, y: 0.5257), CGPoint(x: 0.3450, y: 0.5228), CGPoint(x: 0.3504, y: 0.5191),
        CGPoint(x: 0.3433, y: 0.5368), CGPoint(x: 0.3455, y: 0.5478), CGPoint(x: 0.3482, y: 0.5485),
        CGPoint(x: 0.3515, y: 0.5515), CGPoint(x: 0.3564, y: 0.5522), CGPoint(x: 0.3526, y: 0.5566),
        CGPoint(x: 0.3548, y: 0.5625), CGPoint(x: 0.3548, y: 0.5721), CGPoint(x: 0.3553, y: 0.5831),
        CGPoint(x: 0.3510, y: 0.5978), CGPoint(x: 0.3526, y: 0.6015), CGPoint(x: 0.3662, y: 0.6088),
        CGPoint(x: 0.3662, y: 0.5831), CGPoint(x: 0.3689, y: 0.5713), CGPoint(x: 0.3689, y: 0.5544),
        CGPoint(x: 0.3602, y: 0.5353), CGPoint(x: 0.3580, y: 0.5125), CGPoint(x: 0.3411, y: 0.5088),
        CGPoint(x: 0.3357, y: 0.5140), CGPoint(x: 0.3384, y: 0.5184), CGPoint(x: 0.3390, y: 0.5257)
    ],
    "MAO": [
        CGPoint(x: 0.1101, y: 1.1228), CGPoint(x: 0.1232, y: 1.1000), CGPoint(x: 0.1384, y: 1.0765),
        CGPoint(x: 0.1831, y: 1.0515), CGPoint(x: 0.2163, y: 1.0103), CGPoint(x: 0.2109, y: 0.9853),
        CGPoint(x: 0.1815, y: 0.9618), CGPoint(x: 0.1831, y: 0.9360), CGPoint(x: 0.1809, y: 0.9206),
        CGPoint(x: 0.1918, y: 0.8897), CGPoint(x: 0.2114, y: 0.8257), CGPoint(x: 0.2185, y: 0.8037),
        CGPoint(x: 0.2343, y: 0.7985), CGPoint(x: 0.2741, y: 0.8257), CGPoint(x: 0.2910, y: 0.8353),
        CGPoint(x: 0.3199, y: 0.8346), CGPoint(x: 0.3324, y: 0.7956), CGPoint(x: 0.3253, y: 0.7588),
        CGPoint(x: 0.3221, y: 0.7390), CGPoint(x: 0.2992, y: 0.7176), CGPoint(x: 0.3025, y: 0.7037),
        CGPoint(x: 0.2245, y: 0.6375), CGPoint(x: 0.1515, y: 0.6243), CGPoint(x: 0.1106, y: 0.6353),
        CGPoint(x: 0.1101, y: 1.1228)
    ],
    "MAR": [
        CGPoint(x: 0.4038, y: 0.8088), CGPoint(x: 0.3995, y: 0.8331), CGPoint(x: 0.3929, y: 0.8404),
        CGPoint(x: 0.3853, y: 0.8375), CGPoint(x: 0.3787, y: 0.8441), CGPoint(x: 0.3689, y: 0.8478),
        CGPoint(x: 0.3635, y: 0.8588), CGPoint(x: 0.3542, y: 0.8765), CGPoint(x: 0.3673, y: 0.8882),
        CGPoint(x: 0.3733, y: 0.8904), CGPoint(x: 0.3760, y: 0.8794), CGPoint(x: 0.3875, y: 0.8684),
        CGPoint(x: 0.3995, y: 0.8743), CGPoint(x: 0.4076, y: 0.8757), CGPoint(x: 0.4185, y: 0.8882),
        CGPoint(x: 0.4376, y: 0.8772), CGPoint(x: 0.4343, y: 0.8647), CGPoint(x: 0.4349, y: 0.8537),
        CGPoint(x: 0.4327, y: 0.8434), CGPoint(x: 0.4354, y: 0.8331), CGPoint(x: 0.4327, y: 0.8257),
        CGPoint(x: 0.4349, y: 0.8147), CGPoint(x: 0.4300, y: 0.8140), CGPoint(x: 0.4213, y: 0.8118),
        CGPoint(x: 0.4038, y: 0.8088)
    ],
    "MOS": [
        CGPoint(x: 1.1019, y: 0.2346), CGPoint(x: 0.9488, y: 0.3860), CGPoint(x: 0.8665, y: 0.4301),
        CGPoint(x: 0.7815, y: 0.4647), CGPoint(x: 0.7373, y: 0.5191), CGPoint(x: 0.6975, y: 0.5765),
        CGPoint(x: 0.6839, y: 0.6294), CGPoint(x: 0.6654, y: 0.6529), CGPoint(x: 0.6768, y: 0.6816),
        CGPoint(x: 0.7695, y: 0.6544), CGPoint(x: 0.8185, y: 0.6471), CGPoint(x: 0.8654, y: 0.6368),
        CGPoint(x: 0.9117, y: 0.7044), CGPoint(x: 0.9662, y: 0.7426), CGPoint(x: 0.9891, y: 0.7059),
        CGPoint(x: 1.0327, y: 0.7081), CGPoint(x: 1.0104, y: 0.7647), CGPoint(x: 1.0441, y: 0.7853),
        CGPoint(x: 1.0610, y: 0.8125), CGPoint(x: 1.0883, y: 0.8088), CGPoint(x: 1.0676, y: 0.8287),
        CGPoint(x: 1.0845, y: 0.8485), CGPoint(x: 1.1019, y: 0.8949), CGPoint(x: 1.1025, y: 0.3794),
        CGPoint(x: 1.1019, y: 0.2346)
    ],
    "MUN": [
        CGPoint(x: 0.4469, y: 0.7500), CGPoint(x: 0.4490, y: 0.7581), CGPoint(x: 0.4474, y: 0.7684),
        CGPoint(x: 0.4463, y: 0.7779), CGPoint(x: 0.4594, y: 0.7772), CGPoint(x: 0.4752, y: 0.7794),
        CGPoint(x: 0.4812, y: 0.7809), CGPoint(x: 0.4872, y: 0.7853), CGPoint(x: 0.5008, y: 0.7838),
        CGPoint(x: 0.5177, y: 0.7860), CGPoint(x: 0.5177, y: 0.7757), CGPoint(x: 0.5232, y: 0.7699),
        CGPoint(x: 0.5270, y: 0.7529), CGPoint(x: 0.5166, y: 0.7360), CGPoint(x: 0.5161, y: 0.7176),
        CGPoint(x: 0.5199, y: 0.7140), CGPoint(x: 0.5264, y: 0.7103), CGPoint(x: 0.5215, y: 0.6882),
        CGPoint(x: 0.5095, y: 0.6941), CGPoint(x: 0.5035, y: 0.6985), CGPoint(x: 0.4948, y: 0.7037),
        CGPoint(x: 0.4681, y: 0.7235), CGPoint(x: 0.4561, y: 0.7441), CGPoint(x: 0.4469, y: 0.7500)
    ],
    "NAF": [
        CGPoint(x: 0.1177, y: 1.1228), CGPoint(x: 0.4251, y: 1.1228), CGPoint(x: 0.4322, y: 1.0522),
        CGPoint(x: 0.4196, y: 1.0478), CGPoint(x: 0.4027, y: 1.0456), CGPoint(x: 0.3913, y: 1.0493),
        CGPoint(x: 0.3858, y: 1.0507), CGPoint(x: 0.3738, y: 1.0412), CGPoint(x: 0.3444, y: 1.0382),
        CGPoint(x: 0.3335, y: 1.0368), CGPoint(x: 0.3057, y: 1.0426), CGPoint(x: 0.2986, y: 1.0463),
        CGPoint(x: 0.2937, y: 1.0441), CGPoint(x: 0.2779, y: 1.0515), CGPoint(x: 0.2599, y: 1.0493),
        CGPoint(x: 0.2518, y: 1.0397), CGPoint(x: 0.2458, y: 1.0412), CGPoint(x: 0.2267, y: 1.0338),
        CGPoint(x: 0.2174, y: 1.0132), CGPoint(x: 0.2076, y: 1.0235), CGPoint(x: 0.1591, y: 1.0574),
        CGPoint(x: 0.1444, y: 1.0691), CGPoint(x: 0.1395, y: 1.0772), CGPoint(x: 0.1177, y: 1.1228)
    ],
    "NAO": [
        CGPoint(x: 0.1101, y: 0.1287), CGPoint(x: 0.1935, y: 0.6221), CGPoint(x: 0.2441, y: 0.6309),
        CGPoint(x: 0.2659, y: 0.5912), CGPoint(x: 0.2768, y: 0.5691), CGPoint(x: 0.2839, y: 0.5390),
        CGPoint(x: 0.3052, y: 0.5324), CGPoint(x: 0.3237, y: 0.5199), CGPoint(x: 0.3341, y: 0.5360),
        CGPoint(x: 0.3395, y: 0.5596), CGPoint(x: 0.3471, y: 0.5507), CGPoint(x: 0.3488, y: 0.5169),
        CGPoint(x: 0.3390, y: 0.5272), CGPoint(x: 0.3428, y: 0.5022), CGPoint(x: 0.3499, y: 0.4691),
        CGPoint(x: 0.3662, y: 0.4368), CGPoint(x: 0.3717, y: 0.3382), CGPoint(x: 0.3379, y: 0.2662),
        CGPoint(x: 0.2866, y: 0.2426), CGPoint(x: 0.2747, y: 0.2279), CGPoint(x: 0.2801, y: 0.2051),
        CGPoint(x: 0.2937, y: 0.2074), CGPoint(x: 0.2877, y: 0.1846), CGPoint(x: 0.3030, y: 0.1588),
        CGPoint(x: 0.1101, y: 0.1287)
    ],
    "NAP": [
        CGPoint(x: 0.5608, y: 0.9912), CGPoint(x: 0.5499, y: 0.9816), CGPoint(x: 0.5477, y: 0.9713),
        CGPoint(x: 0.5373, y: 0.9559), CGPoint(x: 0.5302, y: 0.9529), CGPoint(x: 0.5243, y: 0.9610),
        CGPoint(x: 0.5264, y: 0.9676), CGPoint(x: 0.5281, y: 0.9721), CGPoint(x: 0.5362, y: 0.9750),
        CGPoint(x: 0.5401, y: 0.9853), CGPoint(x: 0.5493, y: 0.9978), CGPoint(x: 0.5542, y: 1.0154),
        CGPoint(x: 0.5542, y: 1.0199), CGPoint(x: 0.5493, y: 1.0324), CGPoint(x: 0.5471, y: 1.0419),
        CGPoint(x: 0.5537, y: 1.0412), CGPoint(x: 0.5586, y: 1.0294), CGPoint(x: 0.5608, y: 1.0213),
        CGPoint(x: 0.5662, y: 1.0184), CGPoint(x: 0.5678, y: 1.0110), CGPoint(x: 0.5602, y: 0.9971),
        CGPoint(x: 0.5608, y: 0.9912)
    ],
    "NTH": [
        CGPoint(x: 0.3695, y: 0.4779), CGPoint(x: 0.3815, y: 0.4794), CGPoint(x: 0.3875, y: 0.4971),
        CGPoint(x: 0.3804, y: 0.5397), CGPoint(x: 0.3820, y: 0.5662), CGPoint(x: 0.3853, y: 0.5934),
        CGPoint(x: 0.3853, y: 0.6154), CGPoint(x: 0.3989, y: 0.6199), CGPoint(x: 0.3891, y: 0.6485),
        CGPoint(x: 0.3907, y: 0.6618), CGPoint(x: 0.4022, y: 0.6691), CGPoint(x: 0.4305, y: 0.6434),
        CGPoint(x: 0.4441, y: 0.6110), CGPoint(x: 0.4839, y: 0.5625), CGPoint(x: 0.4828, y: 0.5353),
        CGPoint(x: 0.4812, y: 0.5096), CGPoint(x: 0.4687, y: 0.4919), CGPoint(x: 0.4736, y: 0.4735),
        CGPoint(x: 0.4687, y: 0.4662), CGPoint(x: 0.4692, y: 0.4581), CGPoint(x: 0.4703, y: 0.4426),
        CGPoint(x: 0.4763, y: 0.4103), CGPoint(x: 0.4098, y: 0.4353), CGPoint(x: 0.3787, y: 0.4684),
        CGPoint(x: 0.3695, y: 0.4779)
    ],
    "NWG": [
        CGPoint(x: 0.3052, y: 0.1287), CGPoint(x: 0.3095, y: 0.1875), CGPoint(x: 0.3095, y: 0.2037),
        CGPoint(x: 0.3161, y: 0.1971), CGPoint(x: 0.3243, y: 0.2029), CGPoint(x: 0.3330, y: 0.2096),
        CGPoint(x: 0.3433, y: 0.2118), CGPoint(x: 0.3548, y: 0.2507), CGPoint(x: 0.3635, y: 0.3110),
        CGPoint(x: 0.3689, y: 0.4316), CGPoint(x: 0.3804, y: 0.4559), CGPoint(x: 0.4076, y: 0.4338),
        CGPoint(x: 0.4779, y: 0.4081), CGPoint(x: 0.4997, y: 0.3897), CGPoint(x: 0.5161, y: 0.3750),
        CGPoint(x: 0.5253, y: 0.3654), CGPoint(x: 0.5482, y: 0.3250), CGPoint(x: 0.5678, y: 0.2897),
        CGPoint(x: 0.5886, y: 0.2515), CGPoint(x: 0.5913, y: 0.2404), CGPoint(x: 0.5989, y: 0.2294),
        CGPoint(x: 0.6283, y: 0.2066), CGPoint(x: 0.6381, y: 0.1853), CGPoint(x: 0.6398, y: 0.1287),
        CGPoint(x: 0.3052, y: 0.1287)
    ],
    "NWY": [
        CGPoint(x: 0.6529, y: 0.1934), CGPoint(x: 0.6436, y: 0.1956), CGPoint(x: 0.6174, y: 0.2191),
        CGPoint(x: 0.5956, y: 0.2331), CGPoint(x: 0.5891, y: 0.2529), CGPoint(x: 0.5504, y: 0.3228),
        CGPoint(x: 0.5259, y: 0.3669), CGPoint(x: 0.5084, y: 0.3838), CGPoint(x: 0.4932, y: 0.3934),
        CGPoint(x: 0.4790, y: 0.4088), CGPoint(x: 0.4725, y: 0.4566), CGPoint(x: 0.4687, y: 0.4735),
        CGPoint(x: 0.4752, y: 0.5022), CGPoint(x: 0.5193, y: 0.4838), CGPoint(x: 0.5313, y: 0.4824),
        CGPoint(x: 0.5417, y: 0.4213), CGPoint(x: 0.5510, y: 0.3647), CGPoint(x: 0.5684, y: 0.3191),
        CGPoint(x: 0.5956, y: 0.2625), CGPoint(x: 0.6262, y: 0.2360), CGPoint(x: 0.6567, y: 0.2132),
        CGPoint(x: 0.6817, y: 0.2184), CGPoint(x: 0.6698, y: 0.1971), CGPoint(x: 0.6594, y: 0.1904),
        CGPoint(x: 0.6529, y: 0.1934)
    ],
    "PAR": [
        CGPoint(x: 0.3602, y: 0.7206), CGPoint(x: 0.3597, y: 0.7456), CGPoint(x: 0.3564, y: 0.7838),
        CGPoint(x: 0.3602, y: 0.7897), CGPoint(x: 0.3717, y: 0.7956), CGPoint(x: 0.3798, y: 0.7831),
        CGPoint(x: 0.3831, y: 0.7684), CGPoint(x: 0.3902, y: 0.7632), CGPoint(x: 0.3935, y: 0.7581),
        CGPoint(x: 0.3989, y: 0.7537), CGPoint(x: 0.4033, y: 0.7485), CGPoint(x: 0.4087, y: 0.7441),
        CGPoint(x: 0.4147, y: 0.7294), CGPoint(x: 0.3995, y: 0.7213), CGPoint(x: 0.3896, y: 0.7169),
        CGPoint(x: 0.3820, y: 0.7206), CGPoint(x: 0.3684, y: 0.7221), CGPoint(x: 0.3602, y: 0.7206)
    ],
    "PIC": [
        CGPoint(x: 0.3875, y: 0.6882), CGPoint(x: 0.3804, y: 0.6956), CGPoint(x: 0.3749, y: 0.6963),
        CGPoint(x: 0.3689, y: 0.7000), CGPoint(x: 0.3689, y: 0.7015), CGPoint(x: 0.3711, y: 0.7029),
        CGPoint(x: 0.3711, y: 0.7044), CGPoint(x: 0.3635, y: 0.7059), CGPoint(x: 0.3602, y: 0.7199),
        CGPoint(x: 0.3804, y: 0.7184), CGPoint(x: 0.3896, y: 0.7147), CGPoint(x: 0.3995, y: 0.7184),
        CGPoint(x: 0.4158, y: 0.7272), CGPoint(x: 0.4196, y: 0.7147), CGPoint(x: 0.4060, y: 0.7029),
        CGPoint(x: 0.3875, y: 0.6882)
    ],
    "PIE": [
        CGPoint(x: 0.4381, y: 0.8191), CGPoint(x: 0.4371, y: 0.8265), CGPoint(x: 0.4392, y: 0.8346),
        CGPoint(x: 0.4365, y: 0.8426), CGPoint(x: 0.4387, y: 0.8537), CGPoint(x: 0.4392, y: 0.8706),
        CGPoint(x: 0.4420, y: 0.8743), CGPoint(x: 0.4501, y: 0.8706), CGPoint(x: 0.4621, y: 0.8632),
        CGPoint(x: 0.4736, y: 0.8721), CGPoint(x: 0.4763, y: 0.8640), CGPoint(x: 0.4736, y: 0.8537),
        CGPoint(x: 0.4834, y: 0.8316), CGPoint(x: 0.4828, y: 0.8228), CGPoint(x: 0.4719, y: 0.8206),
        CGPoint(x: 0.4638, y: 0.8287), CGPoint(x: 0.4523, y: 0.8199), CGPoint(x: 0.4381, y: 0.8191)
    ],
    "POR": [
        CGPoint(x: 0.2147, y: 0.8404), CGPoint(x: 0.2098, y: 0.8426), CGPoint(x: 0.2071, y: 0.8537),
        CGPoint(x: 0.2011, y: 0.8728), CGPoint(x: 0.1913, y: 0.8934), CGPoint(x: 0.1831, y: 0.9000),
        CGPoint(x: 0.1809, y: 0.9140), CGPoint(x: 0.1815, y: 0.9184), CGPoint(x: 0.1869, y: 0.9257),
        CGPoint(x: 0.1842, y: 0.9360), CGPoint(x: 0.1820, y: 0.9471), CGPoint(x: 0.1782, y: 0.9574),
        CGPoint(x: 0.1853, y: 0.9632), CGPoint(x: 0.1918, y: 0.9662), CGPoint(x: 0.1978, y: 0.9640),
        CGPoint(x: 0.2022, y: 0.9522), CGPoint(x: 0.2109, y: 0.9360), CGPoint(x: 0.2114, y: 0.9272),
        CGPoint(x: 0.2142, y: 0.9176), CGPoint(x: 0.2147, y: 0.9044), CGPoint(x: 0.2229, y: 0.8934),
        CGPoint(x: 0.2338, y: 0.8676), CGPoint(x: 0.2409, y: 0.8551), CGPoint(x: 0.2245, y: 0.8471),
        CGPoint(x: 0.2147, y: 0.8404)
    ],
    "PRU": [
        CGPoint(x: 0.6245, y: 0.5794), CGPoint(x: 0.6218, y: 0.6007), CGPoint(x: 0.6142, y: 0.6037),
        CGPoint(x: 0.6120, y: 0.6103), CGPoint(x: 0.6082, y: 0.6162), CGPoint(x: 0.5956, y: 0.6176),
        CGPoint(x: 0.5940, y: 0.6110), CGPoint(x: 0.5711, y: 0.6191), CGPoint(x: 0.5504, y: 0.6272),
        CGPoint(x: 0.5526, y: 0.6493), CGPoint(x: 0.5553, y: 0.6603), CGPoint(x: 0.5569, y: 0.6706),
        CGPoint(x: 0.5629, y: 0.6735), CGPoint(x: 0.5782, y: 0.6750), CGPoint(x: 0.5853, y: 0.6743),
        CGPoint(x: 0.5891, y: 0.6647), CGPoint(x: 0.5989, y: 0.6507), CGPoint(x: 0.6234, y: 0.6412),
        CGPoint(x: 0.6436, y: 0.6221), CGPoint(x: 0.6447, y: 0.6132), CGPoint(x: 0.6447, y: 0.6103),
        CGPoint(x: 0.6414, y: 0.5993), CGPoint(x: 0.6327, y: 0.5941), CGPoint(x: 0.6245, y: 0.5794)
    ],
    "ROM": [
        CGPoint(x: 0.5302, y: 0.9493), CGPoint(x: 0.5183, y: 0.9346), CGPoint(x: 0.5134, y: 0.9279),
        CGPoint(x: 0.5117, y: 0.9184), CGPoint(x: 0.5090, y: 0.9066), CGPoint(x: 0.4954, y: 0.9162),
        CGPoint(x: 0.4921, y: 0.9235), CGPoint(x: 0.4981, y: 0.9353), CGPoint(x: 0.5101, y: 0.9522),
        CGPoint(x: 0.5177, y: 0.9537), CGPoint(x: 0.5237, y: 0.9559), CGPoint(x: 0.5302, y: 0.9493)
    ],
    "RUH": [
        CGPoint(x: 0.4480, y: 0.6765), CGPoint(x: 0.4441, y: 0.6912), CGPoint(x: 0.4414, y: 0.6993),
        CGPoint(x: 0.4441, y: 0.7191), CGPoint(x: 0.4403, y: 0.7265), CGPoint(x: 0.4452, y: 0.7463),
        CGPoint(x: 0.4545, y: 0.7426), CGPoint(x: 0.4599, y: 0.7324), CGPoint(x: 0.4708, y: 0.7176),
        CGPoint(x: 0.4817, y: 0.7140), CGPoint(x: 0.4856, y: 0.7103), CGPoint(x: 0.4790, y: 0.6978),
        CGPoint(x: 0.4561, y: 0.6801), CGPoint(x: 0.4480, y: 0.6765)
    ],
    "RUM": [
        CGPoint(x: 0.6959, y: 0.7743), CGPoint(x: 0.6932, y: 0.7890), CGPoint(x: 0.6856, y: 0.7985),
        CGPoint(x: 0.6899, y: 0.8096), CGPoint(x: 0.6975, y: 0.8338), CGPoint(x: 0.6845, y: 0.8456),
        CGPoint(x: 0.6556, y: 0.8551), CGPoint(x: 0.6469, y: 0.8750), CGPoint(x: 0.6507, y: 0.8787),
        CGPoint(x: 0.6545, y: 0.8831), CGPoint(x: 0.6708, y: 0.8860), CGPoint(x: 0.6899, y: 0.8853),
        CGPoint(x: 0.7014, y: 0.8801), CGPoint(x: 0.7297, y: 0.8816), CGPoint(x: 0.7319, y: 0.8618),
        CGPoint(x: 0.7384, y: 0.8515), CGPoint(x: 0.7395, y: 0.8419), CGPoint(x: 0.7243, y: 0.8441),
        CGPoint(x: 0.7177, y: 0.8250), CGPoint(x: 0.7183, y: 0.8162), CGPoint(x: 0.7123, y: 0.7956),
        CGPoint(x: 0.6959, y: 0.7743)
    ],
    "SER": [
        CGPoint(x: 0.6480, y: 0.9566), CGPoint(x: 0.6447, y: 0.9471), CGPoint(x: 0.6485, y: 0.9412),
        CGPoint(x: 0.6452, y: 0.9221), CGPoint(x: 0.6458, y: 0.9154), CGPoint(x: 0.6485, y: 0.9088),
        CGPoint(x: 0.6436, y: 0.8956), CGPoint(x: 0.6436, y: 0.8824), CGPoint(x: 0.6414, y: 0.8699),
        CGPoint(x: 0.6381, y: 0.8691), CGPoint(x: 0.6234, y: 0.8676), CGPoint(x: 0.6163, y: 0.8647),
        CGPoint(x: 0.6109, y: 0.8684), CGPoint(x: 0.6033, y: 0.8684), CGPoint(x: 0.6016, y: 0.8713),
        CGPoint(x: 0.6033, y: 0.8853), CGPoint(x: 0.6011, y: 0.8941), CGPoint(x: 0.6016, y: 0.9103),
        CGPoint(x: 0.6180, y: 0.9279), CGPoint(x: 0.6218, y: 0.9434), CGPoint(x: 0.6223, y: 0.9500),
        CGPoint(x: 0.6234, y: 0.9610), CGPoint(x: 0.6289, y: 0.9625), CGPoint(x: 0.6480, y: 0.9566)
    ],
    "SEV": [
        CGPoint(x: 0.7433, y: 0.8088), CGPoint(x: 0.7700, y: 0.7971), CGPoint(x: 0.7913, y: 0.8125),
        CGPoint(x: 0.8005, y: 0.8500), CGPoint(x: 0.8240, y: 0.8279), CGPoint(x: 0.8016, y: 0.8118),
        CGPoint(x: 0.8441, y: 0.7669), CGPoint(x: 0.8441, y: 0.7846), CGPoint(x: 0.8414, y: 0.8176),
        CGPoint(x: 0.8561, y: 0.8309), CGPoint(x: 0.9139, y: 0.8912), CGPoint(x: 0.9619, y: 0.9154),
        CGPoint(x: 1.0207, y: 0.9051), CGPoint(x: 1.0294, y: 0.8912), CGPoint(x: 1.0109, y: 0.8412),
        CGPoint(x: 0.9711, y: 0.7890), CGPoint(x: 0.9646, y: 0.7500), CGPoint(x: 0.9090, y: 0.7044),
        CGPoint(x: 0.8736, y: 0.6426), CGPoint(x: 0.8229, y: 0.6382), CGPoint(x: 0.7804, y: 0.6647),
        CGPoint(x: 0.7526, y: 0.7566), CGPoint(x: 0.7248, y: 0.7963), CGPoint(x: 0.7395, y: 0.8360),
        CGPoint(x: 0.7433, y: 0.8088)
    ],
    "SIL": [
        CGPoint(x: 0.5232, y: 0.6875), CGPoint(x: 0.5286, y: 0.7088), CGPoint(x: 0.5433, y: 0.7037),
        CGPoint(x: 0.5553, y: 0.7029), CGPoint(x: 0.5689, y: 0.7169), CGPoint(x: 0.5804, y: 0.7235),
        CGPoint(x: 0.6016, y: 0.7228), CGPoint(x: 0.5929, y: 0.7074), CGPoint(x: 0.5858, y: 0.6772),
        CGPoint(x: 0.5662, y: 0.6772), CGPoint(x: 0.5597, y: 0.6757), CGPoint(x: 0.5553, y: 0.6735),
        CGPoint(x: 0.5515, y: 0.6772), CGPoint(x: 0.5460, y: 0.6809), CGPoint(x: 0.5232, y: 0.6875)
    ],
    "SKA": [
        CGPoint(x: 0.4839, y: 0.5096), CGPoint(x: 0.4872, y: 0.5404), CGPoint(x: 0.4883, y: 0.5404),
        CGPoint(x: 0.4986, y: 0.5338), CGPoint(x: 0.5074, y: 0.5279), CGPoint(x: 0.5134, y: 0.5272),
        CGPoint(x: 0.5144, y: 0.5316), CGPoint(x: 0.5134, y: 0.5404), CGPoint(x: 0.5101, y: 0.5500),
        CGPoint(x: 0.5139, y: 0.5566), CGPoint(x: 0.5166, y: 0.5625), CGPoint(x: 0.5210, y: 0.5640),
        CGPoint(x: 0.5319, y: 0.5669), CGPoint(x: 0.5341, y: 0.5559), CGPoint(x: 0.5286, y: 0.5346),
        CGPoint(x: 0.5243, y: 0.5132), CGPoint(x: 0.5221, y: 0.4993), CGPoint(x: 0.5199, y: 0.4860),
        CGPoint(x: 0.5112, y: 0.4926), CGPoint(x: 0.5008, y: 0.4993), CGPoint(x: 0.4839, y: 0.5096)
    ],
    "SMY": [
        CGPoint(x: 0.8916, y: 0.9471), CGPoint(x: 0.8507, y: 0.9640), CGPoint(x: 0.8213, y: 0.9890),
        CGPoint(x: 0.7962, y: 0.9912), CGPoint(x: 0.7635, y: 1.0037), CGPoint(x: 0.7471, y: 1.0037),
        CGPoint(x: 0.7351, y: 1.0059), CGPoint(x: 0.7188, y: 0.9985), CGPoint(x: 0.7155, y: 1.0118),
        CGPoint(x: 0.7144, y: 1.0243), CGPoint(x: 0.7204, y: 1.0397), CGPoint(x: 0.7253, y: 1.0493),
        CGPoint(x: 0.7351, y: 1.0559), CGPoint(x: 0.7384, y: 1.0581), CGPoint(x: 0.7406, y: 1.0632),
        CGPoint(x: 0.7504, y: 1.0647), CGPoint(x: 0.7629, y: 1.0750), CGPoint(x: 0.7804, y: 1.0529),
        CGPoint(x: 0.8087, y: 1.0676), CGPoint(x: 0.8365, y: 1.0441), CGPoint(x: 0.8583, y: 1.0353),
        CGPoint(x: 0.8736, y: 0.9985), CGPoint(x: 0.8937, y: 0.9868), CGPoint(x: 0.8921, y: 0.9618),
        CGPoint(x: 0.8916, y: 0.9471)
    ],
    "SPA": [
        CGPoint(x: 0.2104, y: 0.8368), CGPoint(x: 0.2256, y: 0.8426), CGPoint(x: 0.2452, y: 0.8596),
        CGPoint(x: 0.2218, y: 0.9015), CGPoint(x: 0.2174, y: 0.9162), CGPoint(x: 0.2131, y: 0.9441),
        CGPoint(x: 0.2120, y: 0.9846), CGPoint(x: 0.2251, y: 0.9993), CGPoint(x: 0.2425, y: 0.9978),
        CGPoint(x: 0.2643, y: 1.0051), CGPoint(x: 0.2834, y: 0.9963), CGPoint(x: 0.3155, y: 0.9713),
        CGPoint(x: 0.3161, y: 0.9485), CGPoint(x: 0.3264, y: 0.9309), CGPoint(x: 0.3466, y: 0.9154),
        CGPoint(x: 0.3738, y: 0.8949), CGPoint(x: 0.3444, y: 0.8757), CGPoint(x: 0.3253, y: 0.8669),
        CGPoint(x: 0.3090, y: 0.8463), CGPoint(x: 0.2905, y: 0.8368), CGPoint(x: 0.2757, y: 0.8287),
        CGPoint(x: 0.2441, y: 0.8096), CGPoint(x: 0.2180, y: 0.8051), CGPoint(x: 0.2125, y: 0.8257),
        CGPoint(x: 0.2104, y: 0.8368)
    ],
    "STP": [
        CGPoint(x: 0.8643, y: 0.1287), CGPoint(x: 0.8567, y: 0.1618), CGPoint(x: 0.8387, y: 0.2074),
        CGPoint(x: 0.8294, y: 0.1765), CGPoint(x: 0.8125, y: 0.2235), CGPoint(x: 0.7815, y: 0.2118),
        CGPoint(x: 0.7913, y: 0.2544), CGPoint(x: 0.7646, y: 0.3007), CGPoint(x: 0.7815, y: 0.3250),
        CGPoint(x: 0.7504, y: 0.3346), CGPoint(x: 0.7335, y: 0.3390), CGPoint(x: 0.7101, y: 0.2941),
        CGPoint(x: 0.7204, y: 0.2868), CGPoint(x: 0.7401, y: 0.2360), CGPoint(x: 0.6883, y: 0.2147),
        CGPoint(x: 0.6817, y: 0.2735), CGPoint(x: 0.7041, y: 0.4066), CGPoint(x: 0.7084, y: 0.4640),
        CGPoint(x: 0.6681, y: 0.4824), CGPoint(x: 0.6954, y: 0.5235), CGPoint(x: 0.7575, y: 0.5103),
        CGPoint(x: 0.8278, y: 0.4441), CGPoint(x: 0.9357, y: 0.3926), CGPoint(x: 1.0779, y: 0.2618),
        CGPoint(x: 0.8643, y: 0.1287)
    ],
    "SWE": [
        CGPoint(x: 0.6147, y: 0.2485), CGPoint(x: 0.6060, y: 0.2581), CGPoint(x: 0.5984, y: 0.2662),
        CGPoint(x: 0.5837, y: 0.2963), CGPoint(x: 0.5711, y: 0.3213), CGPoint(x: 0.5602, y: 0.3632),
        CGPoint(x: 0.5466, y: 0.3801), CGPoint(x: 0.5450, y: 0.4169), CGPoint(x: 0.5439, y: 0.4360),
        CGPoint(x: 0.5362, y: 0.4772), CGPoint(x: 0.5237, y: 0.4993), CGPoint(x: 0.5302, y: 0.5375),
        CGPoint(x: 0.5351, y: 0.5779), CGPoint(x: 0.5499, y: 0.5779), CGPoint(x: 0.5673, y: 0.5713),
        CGPoint(x: 0.5749, y: 0.5346), CGPoint(x: 0.5771, y: 0.5125), CGPoint(x: 0.5787, y: 0.5066),
        CGPoint(x: 0.5962, y: 0.4890), CGPoint(x: 0.5875, y: 0.4559), CGPoint(x: 0.5902, y: 0.4110),
        CGPoint(x: 0.6207, y: 0.3507), CGPoint(x: 0.6398, y: 0.3221), CGPoint(x: 0.6311, y: 0.2699),
        CGPoint(x: 0.6147, y: 0.2485)
    ],
    "SYR": [
        CGPoint(x: 1.1019, y: 0.9169), CGPoint(x: 1.0926, y: 0.9324), CGPoint(x: 1.0676, y: 0.9412),
        CGPoint(x: 1.0540, y: 0.9596), CGPoint(x: 1.0196, y: 0.9926), CGPoint(x: 1.0082, y: 0.9941),
        CGPoint(x: 1.0038, y: 0.9949), CGPoint(x: 0.9978, y: 0.9941), CGPoint(x: 0.9444, y: 0.9868),
        CGPoint(x: 0.9041, y: 0.9860), CGPoint(x: 0.8719, y: 1.0037), CGPoint(x: 0.8654, y: 1.0235),
        CGPoint(x: 0.8589, y: 1.0382), CGPoint(x: 0.8578, y: 1.0441), CGPoint(x: 0.8545, y: 1.0537),
        CGPoint(x: 0.8572, y: 1.0728), CGPoint(x: 0.8605, y: 1.0794), CGPoint(x: 0.8616, y: 1.0846),
        CGPoint(x: 0.8621, y: 1.0971), CGPoint(x: 0.8632, y: 1.1096), CGPoint(x: 0.8632, y: 1.1228),
        CGPoint(x: 1.1025, y: 1.1228), CGPoint(x: 1.1025, y: 0.9360), CGPoint(x: 1.1019, y: 0.9169)
    ],
    "TRI": [
        CGPoint(x: 0.5466, y: 0.8022), CGPoint(x: 0.5411, y: 0.8110), CGPoint(x: 0.5253, y: 0.8154),
        CGPoint(x: 0.5270, y: 0.8382), CGPoint(x: 0.5259, y: 0.8471), CGPoint(x: 0.5281, y: 0.8596),
        CGPoint(x: 0.5319, y: 0.8551), CGPoint(x: 0.5390, y: 0.8485), CGPoint(x: 0.5373, y: 0.8684),
        CGPoint(x: 0.5510, y: 0.8875), CGPoint(x: 0.5580, y: 0.8963), CGPoint(x: 0.5706, y: 0.9074),
        CGPoint(x: 0.5798, y: 0.9176), CGPoint(x: 0.5967, y: 0.9338), CGPoint(x: 0.6049, y: 0.9213),
        CGPoint(x: 0.5967, y: 0.9000), CGPoint(x: 0.5995, y: 0.8860), CGPoint(x: 0.5995, y: 0.8654),
        CGPoint(x: 0.5929, y: 0.8596), CGPoint(x: 0.5875, y: 0.8463), CGPoint(x: 0.5771, y: 0.8382),
        CGPoint(x: 0.5684, y: 0.8125), CGPoint(x: 0.5575, y: 0.8176), CGPoint(x: 0.5466, y: 0.8022)
    ],
    "TUN": [
        CGPoint(x: 0.4289, y: 1.1228), CGPoint(x: 0.4670, y: 1.1228), CGPoint(x: 0.4714, y: 1.1221),
        CGPoint(x: 0.4736, y: 1.1162), CGPoint(x: 0.4730, y: 1.0985), CGPoint(x: 0.4665, y: 1.0890),
        CGPoint(x: 0.4649, y: 1.0809), CGPoint(x: 0.4736, y: 1.0662), CGPoint(x: 0.4747, y: 1.0588),
        CGPoint(x: 0.4714, y: 1.0588), CGPoint(x: 0.4638, y: 1.0632), CGPoint(x: 0.4610, y: 1.0544),
        CGPoint(x: 0.4501, y: 1.0493), CGPoint(x: 0.4414, y: 1.0515), CGPoint(x: 0.4365, y: 1.0537),
        CGPoint(x: 0.4300, y: 1.0728), CGPoint(x: 0.4289, y: 1.1228)
    ],
    "TUS": [
        CGPoint(x: 0.4785, y: 0.8662), CGPoint(x: 0.4757, y: 0.8735), CGPoint(x: 0.4774, y: 0.8831),
        CGPoint(x: 0.4785, y: 0.8978), CGPoint(x: 0.4899, y: 0.9213), CGPoint(x: 0.4981, y: 0.9110),
        CGPoint(x: 0.5079, y: 0.9037), CGPoint(x: 0.4965, y: 0.8824), CGPoint(x: 0.4845, y: 0.8721),
        CGPoint(x: 0.4785, y: 0.8662)
    ],
    "TYR": [
        CGPoint(x: 0.4768, y: 0.7846), CGPoint(x: 0.4872, y: 0.8074), CGPoint(x: 0.4861, y: 0.8250),
        CGPoint(x: 0.4921, y: 0.8346), CGPoint(x: 0.4997, y: 0.8272), CGPoint(x: 0.5014, y: 0.8199),
        CGPoint(x: 0.5144, y: 0.8147), CGPoint(x: 0.5226, y: 0.8140), CGPoint(x: 0.5253, y: 0.8103),
        CGPoint(x: 0.5302, y: 0.8081), CGPoint(x: 0.5368, y: 0.8081), CGPoint(x: 0.5417, y: 0.8081),
        CGPoint(x: 0.5450, y: 0.7971), CGPoint(x: 0.5466, y: 0.7684), CGPoint(x: 0.5302, y: 0.7691),
        CGPoint(x: 0.5253, y: 0.7735), CGPoint(x: 0.5215, y: 0.7765), CGPoint(x: 0.5188, y: 0.7904),
        CGPoint(x: 0.5144, y: 0.7897), CGPoint(x: 0.5074, y: 0.7890), CGPoint(x: 0.4959, y: 0.7890),
        CGPoint(x: 0.4856, y: 0.7897), CGPoint(x: 0.4768, y: 0.7846)
    ],
    "TYS": [
        CGPoint(x: 0.4447, y: 1.0051), CGPoint(x: 0.4480, y: 1.0324), CGPoint(x: 0.4463, y: 1.0485),
        CGPoint(x: 0.4632, y: 1.0625), CGPoint(x: 0.4774, y: 1.0529), CGPoint(x: 0.5008, y: 1.0331),
        CGPoint(x: 0.5183, y: 1.0360), CGPoint(x: 0.5357, y: 1.0360), CGPoint(x: 0.5531, y: 1.0199),
        CGPoint(x: 0.5482, y: 0.9978), CGPoint(x: 0.5401, y: 0.9868), CGPoint(x: 0.5351, y: 0.9765),
        CGPoint(x: 0.5232, y: 0.9625), CGPoint(x: 0.5199, y: 0.9559), CGPoint(x: 0.5030, y: 0.9463),
        CGPoint(x: 0.4975, y: 0.9360), CGPoint(x: 0.4823, y: 0.9103), CGPoint(x: 0.4719, y: 0.9007),
        CGPoint(x: 0.4649, y: 0.9007), CGPoint(x: 0.4605, y: 0.9309), CGPoint(x: 0.4572, y: 0.9404),
        CGPoint(x: 0.4621, y: 0.9610), CGPoint(x: 0.4540, y: 1.0000), CGPoint(x: 0.4496, y: 1.0015),
        CGPoint(x: 0.4447, y: 1.0051)
    ],
    "UKR": [
        CGPoint(x: 0.6948, y: 0.7699), CGPoint(x: 0.7144, y: 0.7926), CGPoint(x: 0.7183, y: 0.8000),
        CGPoint(x: 0.7308, y: 0.7853), CGPoint(x: 0.7341, y: 0.7779), CGPoint(x: 0.7422, y: 0.7610),
        CGPoint(x: 0.7504, y: 0.7551), CGPoint(x: 0.7602, y: 0.7478), CGPoint(x: 0.7744, y: 0.7096),
        CGPoint(x: 0.7771, y: 0.6875), CGPoint(x: 0.7787, y: 0.6706), CGPoint(x: 0.7766, y: 0.6596),
        CGPoint(x: 0.7722, y: 0.6574), CGPoint(x: 0.7597, y: 0.6566), CGPoint(x: 0.7379, y: 0.6625),
        CGPoint(x: 0.6948, y: 0.6772), CGPoint(x: 0.6850, y: 0.6809), CGPoint(x: 0.6741, y: 0.6897),
        CGPoint(x: 0.6719, y: 0.7096), CGPoint(x: 0.6703, y: 0.7176), CGPoint(x: 0.6845, y: 0.7316),
        CGPoint(x: 0.6948, y: 0.7640), CGPoint(x: 0.6948, y: 0.7699)
    ],
    "VEN": [
        CGPoint(x: 0.5215, y: 0.9346), CGPoint(x: 0.5253, y: 0.9265), CGPoint(x: 0.5281, y: 0.9206),
        CGPoint(x: 0.5253, y: 0.9118), CGPoint(x: 0.5183, y: 0.8897), CGPoint(x: 0.5057, y: 0.8647),
        CGPoint(x: 0.5084, y: 0.8559), CGPoint(x: 0.5095, y: 0.8456), CGPoint(x: 0.5188, y: 0.8397),
        CGPoint(x: 0.5237, y: 0.8375), CGPoint(x: 0.5259, y: 0.8250), CGPoint(x: 0.5248, y: 0.8213),
        CGPoint(x: 0.5161, y: 0.8191), CGPoint(x: 0.5046, y: 0.8228), CGPoint(x: 0.5030, y: 0.8279),
        CGPoint(x: 0.4905, y: 0.8397), CGPoint(x: 0.4839, y: 0.8353), CGPoint(x: 0.4801, y: 0.8390),
        CGPoint(x: 0.4752, y: 0.8529), CGPoint(x: 0.4817, y: 0.8662), CGPoint(x: 0.4921, y: 0.8750),
        CGPoint(x: 0.5046, y: 0.8919), CGPoint(x: 0.5134, y: 0.9147), CGPoint(x: 0.5150, y: 0.9265),
        CGPoint(x: 0.5215, y: 0.9346)
    ],
    "VIE": [
        CGPoint(x: 0.6087, y: 0.7618), CGPoint(x: 0.6087, y: 0.7566), CGPoint(x: 0.6054, y: 0.7537),
        CGPoint(x: 0.5946, y: 0.7493), CGPoint(x: 0.5853, y: 0.7500), CGPoint(x: 0.5760, y: 0.7471),
        CGPoint(x: 0.5695, y: 0.7485), CGPoint(x: 0.5586, y: 0.7493), CGPoint(x: 0.5515, y: 0.7625),
        CGPoint(x: 0.5466, y: 0.7750), CGPoint(x: 0.5477, y: 0.7978), CGPoint(x: 0.5499, y: 0.8029),
        CGPoint(x: 0.5575, y: 0.8147), CGPoint(x: 0.5640, y: 0.8103), CGPoint(x: 0.5689, y: 0.8088),
        CGPoint(x: 0.5804, y: 0.7926), CGPoint(x: 0.5907, y: 0.7824), CGPoint(x: 0.5940, y: 0.7743),
        CGPoint(x: 0.6033, y: 0.7618), CGPoint(x: 0.6087, y: 0.7618)
    ],
    "WAL": [
        CGPoint(x: 0.3335, y: 0.5956), CGPoint(x: 0.3362, y: 0.6088), CGPoint(x: 0.3215, y: 0.6154),
        CGPoint(x: 0.3275, y: 0.6243), CGPoint(x: 0.3373, y: 0.6353), CGPoint(x: 0.3455, y: 0.6360),
        CGPoint(x: 0.3433, y: 0.6397), CGPoint(x: 0.3286, y: 0.6397), CGPoint(x: 0.3215, y: 0.6412),
        CGPoint(x: 0.3112, y: 0.6529), CGPoint(x: 0.3025, y: 0.6588), CGPoint(x: 0.3074, y: 0.6618),
        CGPoint(x: 0.3134, y: 0.6588), CGPoint(x: 0.3248, y: 0.6632), CGPoint(x: 0.3324, y: 0.6559),
        CGPoint(x: 0.3433, y: 0.6596), CGPoint(x: 0.3597, y: 0.6618), CGPoint(x: 0.3548, y: 0.6412),
        CGPoint(x: 0.3619, y: 0.6265), CGPoint(x: 0.3662, y: 0.6228), CGPoint(x: 0.3662, y: 0.6118),
        CGPoint(x: 0.3515, y: 0.6037), CGPoint(x: 0.3488, y: 0.5956), CGPoint(x: 0.3482, y: 0.5882),
        CGPoint(x: 0.3335, y: 0.5956)
    ],
    "WAR": [
        CGPoint(x: 0.6431, y: 0.6324), CGPoint(x: 0.5995, y: 0.6559), CGPoint(x: 0.5973, y: 0.7081),
        CGPoint(x: 0.6044, y: 0.7191), CGPoint(x: 0.6158, y: 0.7228), CGPoint(x: 0.6278, y: 0.7154),
        CGPoint(x: 0.6322, y: 0.7096), CGPoint(x: 0.6463, y: 0.7154), CGPoint(x: 0.6610, y: 0.7110),
        CGPoint(x: 0.6681, y: 0.7147), CGPoint(x: 0.6714, y: 0.6963), CGPoint(x: 0.6681, y: 0.6750),
        CGPoint(x: 0.6654, y: 0.6676), CGPoint(x: 0.6616, y: 0.6529), CGPoint(x: 0.6507, y: 0.6419),
        CGPoint(x: 0.6431, y: 0.6324)
    ],
    "WES": [
        CGPoint(x: 0.3673, y: 0.9625), CGPoint(x: 0.3635, y: 0.9699), CGPoint(x: 0.3401, y: 0.9713),
        CGPoint(x: 0.3074, y: 0.9772), CGPoint(x: 0.2817, y: 0.9993), CGPoint(x: 0.2670, y: 1.0066),
        CGPoint(x: 0.2463, y: 1.0000), CGPoint(x: 0.2223, y: 1.0029), CGPoint(x: 0.2213, y: 1.0140),
        CGPoint(x: 0.2458, y: 1.0397), CGPoint(x: 0.2561, y: 1.0456), CGPoint(x: 0.2866, y: 1.0419),
        CGPoint(x: 0.2992, y: 1.0441), CGPoint(x: 0.3112, y: 1.0382), CGPoint(x: 0.3455, y: 1.0368),
        CGPoint(x: 0.3809, y: 1.0449), CGPoint(x: 0.3907, y: 1.0478), CGPoint(x: 0.4125, y: 1.0478),
        CGPoint(x: 0.4311, y: 1.0507), CGPoint(x: 0.4463, y: 1.0265), CGPoint(x: 0.4398, y: 0.9985),
        CGPoint(x: 0.4398, y: 0.9735), CGPoint(x: 0.4245, y: 0.9654), CGPoint(x: 0.3771, y: 0.9618),
        CGPoint(x: 0.3673, y: 0.9625)
    ],
    "YOR": [
        CGPoint(x: 0.3706, y: 0.5515), CGPoint(x: 0.3711, y: 0.5574), CGPoint(x: 0.3711, y: 0.5640),
        CGPoint(x: 0.3678, y: 0.5912), CGPoint(x: 0.3689, y: 0.6235), CGPoint(x: 0.3831, y: 0.6154),
        CGPoint(x: 0.3853, y: 0.6118), CGPoint(x: 0.3891, y: 0.6059), CGPoint(x: 0.3837, y: 0.5926),
        CGPoint(x: 0.3875, y: 0.5838), CGPoint(x: 0.3804, y: 0.5647), CGPoint(x: 0.3771, y: 0.5529),
        CGPoint(x: 0.3706, y: 0.5515)
    ],

    ]
}
