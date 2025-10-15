const vec3 blue_shift = vec3(1.0, 1.0, 1.0);
uint pcg(uint v)
{
    uint state = v * 747796405u + 2891336453u;
    uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    return (word >> 22u) ^ word;
}
uvec2 pcg2d(uvec2 v)
{
    v = v * 1664525u + 1013904223u;
    v.x += v.y * 1664525u;
    v.y += v.x * 1664525u;
    v = v ^ (v >> 16u);
    v.x += v.y * 1664525u;
    v.y += v.x * 1664525u;
    v = v ^ (v >> 16u);
    return v;
}
uvec3 pcg3d(uvec3 v) {
    v = v * 1664525u + 1013904223u;
    v.x += v.y * v.z;
    v.y += v.z * v.x;
    v.z += v.x * v.y;
    v ^= v >> 16u;
    v.x += v.y * v.z;
    v.y += v.z * v.x;
    v.z += v.x * v.y;
    return v;
}
float hash11(float p) {
    return float(pcg(uint(p))) / 4294967296.;
}
vec2 hash21(float p) {
    return vec2(pcg2d(uvec2(p, 0))) / 4294967296.;
}
vec3 hash33(vec3 p3) {
    return vec3(pcg3d(uvec3(p3))) / 4294967296.;
}
vec2 norm(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

// 点から線分への距離と位置パラメータを計算
float distanceToSegment(vec2 p, vec2 a, vec2 b, out float h) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec3 base_color = vec3(0.1, 0.5, 2.5);
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    float elapsed = iTime - iTimeCursorChange;
    
    // フェード計算
    float duration = 0.1;
    float fadeIn = smoothstep(0.0, 0.08, elapsed);
    float fadeOut = 1.0 - smoothstep(0.08, duration, elapsed);
    float fade = fadeIn * fadeOut;
    
    if (fade < 0.001) return;
    
    vec2 center = norm(iCurrentCursor.xy, 1.);
    vec2 vu = norm(fragCoord, 1.);
    
    float distToCursor = length(vu - center);
    if (distToCursor > 0.6) return;
    
    float c0 = 0.;
    
    // ビーム設定
    const float TOTAL_BEAMS = 25.0; // ビームの本数
    const float BEAM_LINE_LENGTH_MIN = 0.005; // ビームの最小長さ
    const float BEAM_LINE_LENGTH_MAX = 0.06; // ビームの最大長さ
    const float BEAM_EMISSION_RANGE = 0.1; // ビームが放出される範囲（広く）
    const float BEAM_THICKNESS_MIN = 0.001; // 両端の太さ
    const float BEAM_THICKNESS_MAX = 0.008; // 中央の太さ
    const float TIME_MULTIPLIER = 3.0; // アニメーション速度
    const float COLOR_INTENSITY = 1.2; // 色の強さ
    const float RANDOM_SEED_OFFSET = 50.0;
    const float TWO_PI = 6.283185;
    
    // カーソルオフセット
    vec2 cursorOffset = norm(vec2(
        iCurrentCursor.x + iCurrentCursor.z * 0.5,
        iCurrentCursor.y - iCurrentCursor.w * 0.5
    ), 1.);
    
    for (float i = 0.; i < TOTAL_BEAMS; ++i) {
        // 時間経過でハッシュ値を変化させることで、ビームがリセットされるたびに方向が変わる
        float hashValue = i + RANDOM_SEED_OFFSET * floor(TIME_MULTIPLIER * iTime + hash11(i));
        float t = fract(TIME_MULTIPLIER * iTime + hash11(i));
        
        // 時間とともに変化する角度
        float angle = TWO_PI * hash11(hashValue + 123.456);
        
        // ビームごとにランダムな長さを生成（これも時間で変化）
        float randomLength = mix(BEAM_LINE_LENGTH_MIN, BEAM_LINE_LENGTH_MAX, hash11(hashValue + 789.012));
        
        // ビームの方向ベクトル
        vec2 beamDir = vec2(cos(angle), sin(angle));
        
        // ビームの開始点（中心から放出範囲内のどこか）
        vec2 beamStart = cursorOffset + beamDir * t * BEAM_EMISSION_RANGE;
        // ビームの終了点（開始点からランダムな長さの線を伸ばす）
        vec2 beamEnd = beamStart + beamDir * randomLength;
        
        // 現在のピクセルから線分までの距離と位置パラメータ
        float h;
        float dist = distanceToSegment(vu, beamStart, beamEnd, h);
        
        // 線分上の位置に応じて太さを変化（中央で太く、両端で細く）
        float thicknessModulation = sin(h * 3.14159);
        float thickness = mix(BEAM_THICKNESS_MIN, BEAM_THICKNESS_MAX, thicknessModulation);
        
        // 距離に基づいて輝度を計算
        float intensity = COLOR_INTENSITY * (1.0 - t) * smoothstep(thickness, 0.0, dist);
        c0 += intensity;
    }
    
    // カラー計算
    vec3 rgb = c0 * base_color;
    rgb += hash33(vec3(fragCoord, iTime * 256.)) / 512.;
    
    float mask = clamp(c0 * 0.3, 0.0, 1.0) * fade;
    
    // 加算合成
    fragColor = min(fragColor + vec4(rgb * mask, 0.0), 1.0);
}
