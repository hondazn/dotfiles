// Optimized shader for Retina displays
// Based on original by yakovgal

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

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec3 base_color = vec3(0.1, 0.5, 2.5);
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);

    float elapsed = iTime - iTimeCursorChange;
    
    // フェード計算の最適化
    float duration = 0.1;
    float fadeIn = smoothstep(0.0, 0.08, elapsed);
    float fadeOut = 1.0 - smoothstep(0.08, duration, elapsed);
    float fade = fadeIn * fadeOut;
    
    // 早期終了: フェードが0なら計算不要
    if (fade < 0.001) return;

    vec2 center = norm(iCurrentCursor.xy, 1.);
    vec2 vu = norm(fragCoord, 1.);
    
    // カーソルからの距離で早期終了
    float distToCursor = length(vu - center);
    if (distToCursor > 0.5) return; // 画面外は計算しない
    
    float c0 = 0.;

    // 最適化された定数
    const float TOTAL_PARTICLES = 30.0; // パーティクル数（デフォルト: 50、Retina: 25-30推奨）
    const float PARTICLE_SEPARATION = 80.0; // パーティクルの広がり（デフォルト: 80、Retina: 50-60推奨）
    const float RANDOM_SEED_OFFSET = 50.0;
    const float TIME_MULTIPLIER = 5.0; // 時間の進み具合（デフォルト: 3、Retina: 5推奨）
    const float TWO_PI = 6.283185;
    const float GAUSSIAN_SCALE = -2.0;
    const float COLOR_INTENSITY = 3.0; // 色の強さ: 大きいほど明るい (デフォルト: 2.0)
    const float COLOR_FADE_FACTOR = 0.1; // 粒子サイズ: 小さいほど大きい (デフォルト: 0.3)
    
    // カーソルオフセットを事前計算
    vec2 cursorOffset = vec2(
        iCurrentCursor.x + iCurrentCursor.z * 0.5,
        iCurrentCursor.y - iCurrentCursor.w * 0.5
    );

    for (float i = 0.; i < TOTAL_PARTICLES; ++i) {
        float hashValue = i + RANDOM_SEED_OFFSET * floor(TIME_MULTIPLIER * iTime + hash11(i));
        float t = fract(TIME_MULTIPLIER * iTime + hash11(i));
        vec2 v = hash21(hashValue);
        
        // ガウス分布での位置計算
        float r = sqrt(GAUSSIAN_SCALE * log(1. - v.x));
        float angle = TWO_PI * v.y;
        v = PARTICLE_SEPARATION * r * vec2(cos(angle), sin(angle));

        vec2 p = center + t * v - fragCoord + cursorOffset;
        
        // 距離ベースの早期スキップ
        float distSq = dot(p, p);
        if (distSq > 10000.0) continue; // 遠すぎるパーティクルはスキップ
        
        c0 += COLOR_INTENSITY * (1. - t) / (1. + COLOR_FADE_FACTOR * distSq);
    }

    // カラー計算
    vec3 rgb = c0 * base_color;
    rgb += hash33(vec3(fragCoord, iTime * 256.)) / 512.;
    
    float mask = clamp(c0 * 0.2, 0.0, 1.0) * fade;
    
    // 加算合成
    fragColor = min(fragColor + vec4(rgb * mask, 0.0), 1.0);
}
