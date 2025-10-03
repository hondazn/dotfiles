// 定数定義
const float PI = 3.14159265359;
const vec4 LIGHTNING_CORE = vec4(1.0, 0.9, 1.0, 1.0);
const vec4 LIGHTNING_BRIGHT = vec4(0.8, 0.4, 1.0, 1.0);
const vec4 LIGHTNING_GLOW = vec4(0.5, 0.3, 0.8, 1.0);
const float DURATION = 0.3;
const int SEGMENTS = 12;
const int BRANCHES = 4;
const int BRANCH_SEGS = 5;

float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b) {
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

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

// 線分までの距離の二乗（sqrt省略版）
float sdSegmentSq(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    vec2 diff = pa - ba * h;
    return dot(diff, diff);
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
    s *= mix(1.0, -1.0, step(0.5, allCond + noneCond));
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

vec2 getRectangleCenter(vec4 rectangle) {
    return vec2(rectangle.x + rectangle.z * 0.5, rectangle.y - rectangle.w * 0.5);
}

float ease(float x) {
    float t = 1.0 - x;
    return t * t * t;
}

// 垂直ベクトル計算を最適化
vec2 perpendicular(vec2 v) {
    return vec2(-v.y, v.x);
}

// 稲妻パス計算（距離の二乗を使用して最後にsqrt）
float getLightningPath(vec2 uv, vec2 start, vec2 end, float time, float seed, out float thickness) {
    vec2 dir = end - start;
    float totalLengthSq = dot(dir, dir);
    
    // Early exit
    if (totalLengthSq < 1e-6) {
        thickness = 1.0;
        return 1e10;
    }
    
    float totalLength = sqrt(totalLengthSq);
    vec2 perpDir = perpendicular(dir) / totalLength; // 正規化を兼ねる
    
    vec2 prevPoint = start;
    float closestDistSq = 1e20;
    float finalThickness = 1.0;
    
    // 時間とシード値を事前計算
    float timeOffset = time * 2.0 + seed;
    float seedBase = seed * 10.0;
    
    for (int i = 1; i <= SEGMENTS; i++) {
        float t = float(i) / float(SEGMENTS);
        vec2 basePoint = mix(start, end, t);
        
        // ノイズ計算の最適化
        float noiseVal = noise(vec2(float(i) * 2.0 + seedBase, timeOffset));
        float amplitude = sin(t * PI) * 1.5;
        float offset = (noiseVal - 0.5) * 0.15 * totalLength * amplitude;
        
        vec2 currentPoint = basePoint + perpDir * offset;
        
        // 二乗距離で比較（sqrtを遅延）
        float segDistSq = sdSegmentSq(uv, prevPoint, currentPoint);
        
        if (segDistSq < closestDistSq) {
            closestDistSq = segDistSq;
            finalThickness = 0.5 + noise(vec2(float(i) + seed * 20.0, seed * 15.0));
        }
        
        prevPoint = currentPoint;
    }
    
    thickness = finalThickness;
    return sqrt(closestDistSq);
}

// 枝稲妻の最適化
float getBranchLightning(vec2 uv, vec2 start, vec2 end, float time, float seed, out float thickness) {
    vec2 mainDir = end - start;
    float totalLengthSq = dot(mainDir, mainDir);
    
    if (totalLengthSq < 1e-6) {
        thickness = 0.5;
        return 1e10;
    }
    
    float totalLength = sqrt(totalLengthSq);
    vec2 mainDirNorm = mainDir / totalLength;
    vec2 perpDir = perpendicular(mainDirNorm);
    
    float minDistSq = 1e20;
    float finalThickness = 0.5;
    
    // 事前計算
    float timeOffset = time * 3.0;
    
    for (int b = 0; b < BRANCHES; b++) {
        float fb = float(b);
        float branchStart = 0.2 + fb * 0.2;
        vec2 startPos = mix(start, end, branchStart);
        
        // 枝の方向計算の最適化
        float branchAngle = (noise(vec2(fb + seed * 5.0, seed * 7.0)) - 0.5) * 1.5;
        float sinAngle = sin(branchAngle);
        float cosAngle = cos(branchAngle);
        vec2 branchDir = perpDir * sinAngle + mainDirNorm * cosAngle;
        
        float branchLength = totalLength * (0.15 + noise(vec2(fb + seed * 3.0, seed)) * 0.15);
        vec2 endPos = startPos + branchDir * branchLength;
        
        vec2 prevPoint = startPos;
        
        for (int i = 1; i <= BRANCH_SEGS; i++) {
            float t = float(i) / float(BRANCH_SEGS);
            vec2 basePoint = mix(startPos, endPos, t);
            
            float noiseVal = noise(vec2(float(i) * 3.0 + fb * 10.0 + seed * 15.0, timeOffset));
            float offset = (noiseVal - 0.5) * 0.08 * branchLength;
            
            vec2 currentPoint = basePoint + perpDir * offset;
            float segDistSq = sdSegmentSq(uv, prevPoint, currentPoint);
            
            if (segDistSq < minDistSq) {
                minDistSq = segDistSq;
                finalThickness = 0.3 + noise(vec2(float(i) + fb * 5.0 + seed * 25.0, seed * 18.0)) * 0.4;
            }
            
            prevPoint = currentPoint;
        }
    }
    
    thickness = finalThickness;
    return sqrt(minDistSq);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // フェードアウト
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy) * 0.92;
    
    vec2 vu = norm(fragCoord, 1.0);
    vec4 currentCursor = vec4(norm(iCurrentCursor.xy, 1.0), norm(iCurrentCursor.zw, 0.0));
    vec4 previousCursor = vec4(norm(iPreviousCursor.xy, 1.0), norm(iPreviousCursor.zw, 0.0));

    vec2 centerCC = getRectangleCenter(currentCursor);
    vec2 centerCP = getRectangleCenter(previousCursor);

    float progress = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
    
    // Early exit - 稲妻が完全に消えたら処理スキップ
    if (progress >= 1.0) return;
    
    float lineLength = distance(centerCC, centerCP);
    // 移動距離が1文字分以下の場合はエフェクトなし
    if (lineLength <= 0.025) return;
    
    float easedProgress = ease(progress);
    float seed = fract(iTimeCursorChange * 12.345);
    
    // 稲妻の描画
    float mainThickness, branchThickness;
    float mainDist = getLightningPath(vu, centerCP, centerCC, iTime, seed, mainThickness);
    float branchDist = getBranchLightning(vu, centerCP, centerCC, iTime, seed, branchThickness);
    
    // 進行度計算
    vec2 pathDir = centerCC - centerCP;
    float pathLengthSq = dot(pathDir, pathDir);
    float pixelProgress = clamp(dot(vu - centerCP, pathDir) / pathLengthSq, 0.0, 1.0);
    
    float reveal = smoothstep(pixelProgress - 0.1, pixelProgress, easedProgress);
    float disappear = 1.0 - smoothstep(pixelProgress, pixelProgress + 0.3, progress);
    float intensity = reveal * disappear;
    
    // Early exit - この位置に稲妻が描画されない場合
    if (intensity < 0.001) return;
    
    // メイン稲妻のレイヤー
    float mainCore = smoothstep(0.004 * mainThickness, 0.0, mainDist);
    float mainBright = smoothstep(0.012 * mainThickness, 0.0, mainDist);
    float mainGlow = smoothstep(0.045 * mainThickness, 0.0, mainDist);
    
    // 枝稲妻のレイヤー
    float branchCore = smoothstep(0.003 * branchThickness, 0.0, branchDist);
    float branchBright = smoothstep(0.010 * branchThickness, 0.0, branchDist);
    float branchGlow = smoothstep(0.035 * branchThickness, 0.0, branchDist);
    
    // 合成を最適化（mix連鎖を減らす）
    vec4 lightning = LIGHTNING_GLOW * (mainGlow * intensity * 0.4 + branchGlow * intensity * 0.21);
    lightning = mix(lightning, LIGHTNING_BRIGHT, (mainBright * intensity + branchBright * intensity * 0.56));
    lightning = mix(lightning, LIGHTNING_CORE, (mainCore * intensity + branchCore * intensity * 0.63));
    
    // 初期フラッシュ
    float flash = exp(-progress * 10.0) * 0.4;
    lightning += LIGHTNING_CORE * (flash * (mainGlow + branchGlow * 0.5) * intensity);
    
    fragColor = max(fragColor, lightning);
}
