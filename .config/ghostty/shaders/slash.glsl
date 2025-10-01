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

// 線分までの距離を計算
float sdSegment(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec3 base_color = vec3(0.3, 0.6, 2.2);
    
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);

    float elapsed = iTime - iTimeCursorChange;

    float duration = 0.15; // エフェクトの持続時間（短いほど早く消える）
    float fadeInTime = 0.02;
    float fadeOutTime = 0.13;
    float fadeIn = smoothstep(0.0, fadeInTime, elapsed);
    float fadeOut = 1.0 - smoothstep(duration - fadeOutTime, duration, elapsed);
    float fade = clamp(fadeIn * fadeOut, 0.0, 1.0);

    // 正規化座標系で計算（元のコードと同じアプローチ）
    vec2 cursorPos = norm(iCurrentCursor.xy, 1.);
    vec2 vu = norm(fragCoord, 1.);
    
    // カーソルのサイズも正規化
    vec2 cursorSize = norm(iCurrentCursor.zw, 0.);
    
    // カーソルの中心位置を計算（元のコードと同じ方法）
    vec2 offsetFactor = vec2(-0.5, 0.5);
    vec2 cursorCenter = cursorPos - (cursorSize * offsetFactor);

    // === スラッシュエフェクト設定 ===
    const float SLASH_LENGTH = 0.24; // スラッシュの長さ（正規化座標）
    const float TIME_MULTIPLIER = 2.0; // スピード（小さいほど遅い）
    
    // ランダムなスラッシュの角度を生成（カーソル位置とタイムスタンプを組み合わせてシード化）
    float randomSeed = iTimeCursorChange + dot(iCurrentCursor.xy, vec2(12.9898, 78.233));
    float randomAngle = hash11(randomSeed) * 6.283185; // 0〜2πのランダムな角度
    vec2 slashDir = vec2(cos(randomAngle), sin(randomAngle));
    
    // スラッシュのアニメーション
    float t = TIME_MULTIPLIER * elapsed;
    t = clamp(t, 0.0, 1.0);
    
    // カーソルの中心を貫くスラッシュの開始位置と終了位置（正規化座標）
    vec2 slashStart = cursorCenter - slashDir * SLASH_LENGTH * 0.5;
    vec2 slashEnd = cursorCenter + slashDir * SLASH_LENGTH * 0.5;
    
    // 現在のピクセルから線分までの距離（正規化座標で計算）
    float dist = sdSegment(vu, slashStart, slashEnd);
    
    // 線上の位置を計算（0.0 = 始点, 1.0 = 終点）
    vec2 pa = vu - slashStart;
    vec2 ba = slashEnd - slashStart;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    
    // 太さの変化：中央が太く、両端が細い（ゲームっぽい剣の軌跡）
    float widthProfile = sin(h * 3.14159) * 1.5 + 0.3;
    
    // グロー効果を最適化（レイヤーを減らして軽量化）
    float coreGlow = exp(-dist * 250.0 / widthProfile) * (1.0 - t * 0.4);
    float outerGlow = exp(-dist * 60.0 / widthProfile) * (1.0 - t * 0.7) * 0.5;
    
    float c0 = (coreGlow * 4.0 + outerGlow * 2.0);

    // 色の合成
    vec3 rgb = c0 * base_color;
    rgb += hash33(vec3(fragCoord, iTime * 256.)) / 1024.;
    rgb = pow(rgb, vec3(0.4545));
    rgb *= fade;
    
    // 加算合成
    float mask = clamp(c0 * 0.15, 0.0, 1.0) * fade;
    vec4 newColor = fragColor + vec4(rgb * mask, 0.0);
    
    fragColor = min(newColor, 1.0);
}
