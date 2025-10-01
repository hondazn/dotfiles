float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

// 2Dノイズ関数
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// 線分までの距離
float sdSegment(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    float segd = dot(p - proj, p - proj);
    d = min(d, segd);

    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float allCond = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    float flip = mix(1.0, -1.0, step(0.5, allCond + noneCond));
    s *= flip;
    return d;
}

float getSdfParallelogram(in vec2 p, in vec2 v0, in vec2 v1, in vec2 v2, in vec2 v3) {
    float s = 1.0;
    float d = dot(p - v0, p - v0);

    d = seg(p, v0, v3, s, d);
    d = seg(p, v1, v0, s, d);
    d = seg(p, v2, v1, s, d);
    d = seg(p, v3, v2, s, d);

    return s * sqrt(d);
}

vec2 norm(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float determineStartVertexFactor(vec2 c, vec2 p) {
    float condition1 = step(p.x, c.x) * step(c.y, p.y);
    float condition2 = step(c.x, p.x) * step(p.y, c.y);
    return 1.0 - max(condition1, condition2);
}

float isLess(float c, float p) {
    return 1.0 - step(p, c);
}

vec2 getRectangleCenter(vec4 rectangle) {
    return vec2(rectangle.x + (rectangle.z / 2.), rectangle.y - (rectangle.w / 2.));
}

float ease(float x) {
    return pow(1.0 - x, 3.0);
}

// 稲妻のパスを計算（太さ情報付き）
float getLightningPath(vec2 uv, vec2 start, vec2 end, float time, float seed, out float thickness) {
    float dist = 1e10;
    vec2 dir = end - start;
    float totalLength = length(dir);
    
    if (totalLength < 0.001) {
        thickness = 1.0;
        return dist;
    }
    
    vec2 perpDir = normalize(vec2(-dir.y, dir.x));
    
    // 稲妻のセグメント数
    const int segments = 12;
    
    vec2 prevPoint = start;
    float closestDist = 1e10;
    
    for (int i = 1; i <= segments; i++) {
        float t = float(i) / float(segments);
        vec2 basePoint = mix(start, end, t);
        
        // ノイズでジグザグを作成
        float noiseVal = noise(vec2(float(i) * 2.0 + seed * 10.0, time * 2.0 + seed));
        float offset = (noiseVal - 0.5) * 0.15 * totalLength;
        
        // 中央部分でより大きく揺らす
        float amplitude = sin(t * 3.14159) * 1.5;
        offset *= amplitude;
        
        vec2 currentPoint = basePoint + perpDir * offset;
        
        // このセグメントまでの距離を計算
        float segDist = sdSegment(uv, prevPoint, currentPoint);
        
        if (segDist < closestDist) {
            closestDist = segDist;
            // このセグメントの太さをランダムに（0.5〜1.5倍）
            thickness = 0.5 + noise(vec2(float(i) + seed * 20.0, seed * 15.0)) * 1.0;
        }
        
        dist = min(dist, segDist);
        prevPoint = currentPoint;
    }
    
    return dist;
}

// 枝稲妻を生成
float getBranchLightning(vec2 uv, vec2 start, vec2 end, float time, float seed, out float thickness) {
    float dist = 1e10;
    vec2 mainDir = end - start;
    float totalLength = length(mainDir);
    
    if (totalLength < 0.001) {
        thickness = 0.5;
        return dist;
    }
    
    vec2 perpDir = normalize(vec2(-mainDir.y, mainDir.x));
    
    // 枝の数（3-5本程度）
    const int branches = 4;
    
    for (int b = 0; b < branches; b++) {
        // 枝の開始位置（メイン稲妻の途中から）
        float branchStart = 0.2 + float(b) * 0.2;
        vec2 startPos = mix(start, end, branchStart);
        
        // 枝の方向（横にずれる）
        float branchAngle = (noise(vec2(float(b) + seed * 5.0, seed * 7.0)) - 0.5) * 1.5;
        vec2 branchDir = perpDir * sin(branchAngle) + normalize(mainDir) * cos(branchAngle);
        float branchLength = totalLength * (0.15 + noise(vec2(float(b) + seed * 3.0, seed)) * 0.15);
        vec2 endPos = startPos + branchDir * branchLength;
        
        // 枝のセグメント（少なめ）
        const int branchSegs = 5;
        vec2 prevPoint = startPos;
        
        for (int i = 1; i <= branchSegs; i++) {
            float t = float(i) / float(branchSegs);
            vec2 basePoint = mix(startPos, endPos, t);
            
            // 枝のジグザグ（小さめ）
            float noiseVal = noise(vec2(float(i) * 3.0 + float(b) * 10.0 + seed * 15.0, time * 3.0));
            float offset = (noiseVal - 0.5) * 0.08 * branchLength;
            
            vec2 currentPoint = basePoint + perpDir * offset;
            
            float segDist = sdSegment(uv, prevPoint, currentPoint);
            
            if (segDist < dist) {
                // 枝は細め（0.3〜0.7倍）
                thickness = 0.3 + noise(vec2(float(i) + float(b) * 5.0 + seed * 25.0, seed * 18.0)) * 0.4;
            }
            
            dist = min(dist, segDist);
            prevPoint = currentPoint;
        }
    }
    
    return dist;
}

const vec4 LIGHTNING_CORE = vec4(1.0, 0.9, 1.0, 1.0);
const vec4 LIGHTNING_BRIGHT = vec4(0.8, 0.4, 1.0, 1.0);
const vec4 LIGHTNING_GLOW = vec4(0.5, 0.3, 0.8, 1.0);
const float DURATION = 0.3;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // 前のフレームを読み込み、徐々にフェードアウト
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    fragColor *= 0.92; // 残像のフェード速度
    
    vec2 vu = norm(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);

    vec4 currentCursor = vec4(norm(iCurrentCursor.xy, 1.), norm(iCurrentCursor.zw, 0.));
    vec4 previousCursor = vec4(norm(iPreviousCursor.xy, 1.), norm(iPreviousCursor.zw, 0.));

    vec2 centerCC = getRectangleCenter(currentCursor);
    vec2 centerCP = getRectangleCenter(previousCursor);
    
    float sdfCurrentCursor = getSdfRectangle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);

    float progress = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
    float easedProgress = ease(progress);
    float lineLength = distance(centerCC, centerCP);

    // 稲妻の軌跡を描画
    if (lineLength > 0.01 && progress < 1.0) {
        float seed = fract(iTimeCursorChange * 12.345);
        
        // メイン稲妻
        float mainThickness;
        float mainLightningDist = getLightningPath(vu, centerCP, centerCC, iTime, seed, mainThickness);
        
        // 枝稲妻
        float branchThickness;
        float branchLightningDist = getBranchLightning(vu, centerCP, centerCC, iTime, seed, branchThickness);
        
        // 各ピクセルが軌跡上のどの位置にあるか (0=開始点, 1=終了点)
        vec2 toPixel = vu - centerCP;
        vec2 pathDir = centerCC - centerCP;
        float pixelProgress = clamp(dot(toPixel, pathDir) / dot(pathDir, pathDir), 0.0, 1.0);
        
        // 稲妻が伸びていくアニメーション (0から1に向かって伸びる)
        float reveal = smoothstep(pixelProgress - 0.1, pixelProgress, easedProgress);
        
        // 稲妻が消えていくアニメーション (0から1に向かって消える)
        float disappear = 1.0 - smoothstep(pixelProgress, pixelProgress + 0.3, progress);
        
        // 全体の強度 (伸びる × 消える)
        float intensity = reveal * disappear;
        
        // === メイン稲妻の描画 ===
        float mainCoreWidth = 0.004 * mainThickness;
        float mainCore = smoothstep(mainCoreWidth, 0.0, mainLightningDist);
        
        float mainBrightWidth = 0.012 * mainThickness;
        float mainBright = smoothstep(mainBrightWidth, 0.0, mainLightningDist);
        
        float mainGlowWidth = 0.045 * mainThickness;
        float mainGlow = smoothstep(mainGlowWidth, 0.0, mainLightningDist);
        
        // === 枝稲妻の描画 ===
        float branchCoreWidth = 0.003 * branchThickness;
        float branchCore = smoothstep(branchCoreWidth, 0.0, branchLightningDist);
        
        float branchBrightWidth = 0.010 * branchThickness;
        float branchBright = smoothstep(branchBrightWidth, 0.0, branchLightningDist);
        
        float branchGlowWidth = 0.035 * branchThickness;
        float branchGlow = smoothstep(branchGlowWidth, 0.0, branchLightningDist);
        
        // レイヤーを合成（メイン + 枝）
        vec4 lightning = vec4(0.0);
        
        // メイン稲妻
        lightning = mix(lightning, LIGHTNING_GLOW * 0.4, mainGlow * intensity);
        lightning = mix(lightning, LIGHTNING_BRIGHT, mainBright * intensity);
        lightning = mix(lightning, LIGHTNING_CORE, mainCore * intensity);
        
        // 枝稲妻（少し暗め）
        lightning = mix(lightning, LIGHTNING_GLOW * 0.3, branchGlow * intensity * 0.7);
        lightning = mix(lightning, LIGHTNING_BRIGHT * 0.8, branchBright * intensity * 0.7);
        lightning = mix(lightning, LIGHTNING_CORE * 0.9, branchCore * intensity * 0.7);
        
        // 初期フラッシュ効果
        float flash = exp(-progress * 10.0) * 0.4;
        lightning += LIGHTNING_CORE * flash * (mainGlow + branchGlow * 0.5) * intensity;
        
        fragColor = max(fragColor, lightning);
    }
    
    // カーソル自体の描画（アウトライン + 点滅）
    float cursorOutlineThickness = 0.002;
    float cursorOutline = smoothstep(cursorOutlineThickness, 0.0, abs(sdfCurrentCursor)) - 
                          smoothstep(0.0, -cursorOutlineThickness, sdfCurrentCursor);
    
    // 点滅効果（約1秒周期）
    float blink = 0.5 + 0.5 * sin(iTime * 3.14159 * 2.0);
    blink = smoothstep(0.3, 0.7, blink); // シャープな点滅
    
    vec4 cursorColor = vec4(0.8, 0.5, 1.0, 1.0);
    
    // アウトラインの描画
    fragColor = mix(fragColor, cursorColor, cursorOutline * 0.9);
    
    // 点滅するグロー
    float cursorGlow = smoothstep(0.008, 0.0, abs(sdfCurrentCursor));
    fragColor = mix(fragColor, cursorColor * 0.4, cursorGlow * blink * 0.5);
}
