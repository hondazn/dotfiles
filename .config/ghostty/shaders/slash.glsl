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

// 線分までの距離を計算（hパラメータ付き）
float sdSegmentWithH(vec2 p, vec2 a, vec2 b, out float h) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
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
    float duration = 0.15;
    float fadeInTime = 0.02;
    float fadeOutTime = 0.02;
    float fadeIn = smoothstep(0.0, fadeInTime, elapsed);
    float fadeOut = 1.0 - smoothstep(duration - fadeOutTime, duration, elapsed);
    float fade = clamp(fadeIn * fadeOut, 0.0, 1.0);
    vec2 cursorPos = norm(iCurrentCursor.xy, 1.);
    vec2 vu = norm(fragCoord, 1.);
    vec2 cursorSize = norm(iCurrentCursor.zw, 0.);
    vec2 offsetFactor = vec2(-0.5, 0.5);
    vec2 cursorCenter = cursorPos - (cursorSize * offsetFactor);
    
    // === スラッシュエフェクト設定 ===
    const float TIME_MULTIPLIER = 12.0;
    const float SLASH_LENGTH = 0.20;
    
    // スラッシュの向きを上から下の垂直方向に固定
    vec2 slashDir = vec2(0.0, -1.0); // 上から下への垂直方向
    
    // スラッシュのアニメーション
    float t = TIME_MULTIPLIER * elapsed;
    t = clamp(t, 0.0, 1.0);
    
    // 直線の始点と終点を逆に（上から下の順序に）
    vec2 slashStart = cursorCenter + slashDir * SLASH_LENGTH * 0.5; // 上
    vec2 slashEnd = cursorCenter - slashDir * SLASH_LENGTH * 0.5; // 下
    
    // 直線までの距離を計算
    float h;
    float dist = sdSegmentWithH(vu, slashStart, slashEnd, h);
    
    // 上から下にフェードイン（上が先に表示される）
    float fadeInSpeed = 3.0;
    float fadeInEdge = t * fadeInSpeed;
    // h < fadeInEdge の部分を表示
    float fadeInProgress = 1.0 - smoothstep(fadeInEdge, fadeInEdge + 0.15, h);
    
    // 上から下にフェードアウト（上が先に消える）
    float fadeOutStart = 0.5;
    float fadeOutSpeed = 3.0;
    float fadeOutEdge = (t - fadeOutStart) * fadeOutSpeed;
    // h < fadeOutEdge の部分を非表示
    float fadeOutProgress = smoothstep(fadeOutEdge, fadeOutEdge + 0.15, h);
    
    // 前半はフェードインのみ、後半はフェードアウトも適用
    float drawProgress = t < fadeOutStart ? fadeInProgress : fadeInProgress * fadeOutProgress;
    
    // 太さの変化：中央が太く、両端が細い
    float widthProfile = sin(h * 3.14159) * 1.5 + 0.3;
    
    // グロー効果
    float coreGlow = exp(-dist * 250.0 / widthProfile) * drawProgress;
    float outerGlow = exp(-dist * 60.0 / widthProfile) * 0.5 * drawProgress;
    
    float c0 = (coreGlow * 4.0 + outerGlow * 2.0);
    
    // 色の合成
    vec3 slashColor = c0 * base_color * fade;
    vec3 rgb = slashColor;
    rgb += hash33(vec3(fragCoord, iTime * 256.)) / 1024.;
    rgb = pow(rgb, vec3(0.4545));
    
    // 加算合成
    float slashMask = clamp(c0 * 0.15, 0.0, 1.0) * fade;
    vec4 newColor = fragColor + vec4(rgb * slashMask, 0.0);
    
    fragColor = min(newColor, 1.0);
}
