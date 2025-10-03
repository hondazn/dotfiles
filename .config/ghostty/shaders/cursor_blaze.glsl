float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
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

const vec4 TRAIL_COLOR = vec4(1.0, 0.9, 1.0, 1.0);
const vec4 TRAIL_COLOR_ACCENT = vec4(0.8, 0.4, 1.0, 1.0);
const float DURATION = 0.3;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // 正規化の事前計算（iResolution.yで1回だけ除算）
    float invResY = 1.0 / iResolution.y;
    vec2 resXY = iResolution.xy;
    
    // 正規化処理をインライン化
    vec2 vu = (fragCoord * 2.0 - resXY) * invResY;
    
    // カーソル情報の正規化を一度に処理
    vec4 currentCursor = (vec4(iCurrentCursor.xy * 2.0 - resXY, iCurrentCursor.zw * 2.0) * invResY);
    vec4 previousCursor = (vec4(iPreviousCursor.xy * 2.0 - resXY, iPreviousCursor.zw * 2.0) * invResY);
    
    // カーソル中心の計算（zw * 0.5を事前計算）
    vec2 curHalfSize = currentCursor.zw * 0.5;
    vec2 prevHalfSize = previousCursor.zw * 0.5;
    vec2 centerCC = currentCursor.xy + vec2(curHalfSize.x, -curHalfSize.y);
    vec2 centerCP = previousCursor.xy + vec2(prevHalfSize.x, -prevHalfSize.y);
    
    // 距離計算（早期判定のため前に移動）
    vec2 centerDiff = centerCC - centerCP;
    float lineLength = sqrt(dot(centerDiff, centerDiff));
    
    // 移動距離が1文字分以下の場合はエフェクトなし
    if (lineLength <= 0.025) {
        fragColor = texture(iChannel0, fragCoord / resXY);
        return;
    }
    
    // 頂点要素の計算（元のロジックを保持）
    float condition1 = step(previousCursor.x, currentCursor.x) * step(currentCursor.y, previousCursor.y);
    float condition2 = step(currentCursor.x, previousCursor.x) * step(previousCursor.y, currentCursor.y);
    float vertexFactor = 1.0 - max(condition1, condition2);
    float invertedVertexFactor = 1.0 - vertexFactor;
    float xFactor = 1.0 - step(currentCursor.x, previousCursor.x);
    float yFactor = 1.0 - step(previousCursor.y, currentCursor.y);

    // パラレログラムの頂点
    vec2 v0 = vec2(currentCursor.x + currentCursor.z * vertexFactor, currentCursor.y - currentCursor.w);
    vec2 v1 = vec2(currentCursor.x + currentCursor.z * xFactor, currentCursor.y - currentCursor.w * yFactor);
    vec2 v2 = vec2(currentCursor.x + currentCursor.z * invertedVertexFactor, currentCursor.y);
    vec2 v3 = centerCP;

    // SDF計算（offsetFactorを正しく適用: x方向は+、y方向は-）
    float sdfCurrentCursor = getSdfRectangle(vu, currentCursor.xy + vec2(curHalfSize.x, -curHalfSize.y), curHalfSize);
    float sdfTrail = getSdfParallelogram(vu, v0, v1, v2, v3);

    // プログレス計算（pow最適化）
    float progress = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
    float easedProgress = (1.0 - progress) * (1.0 - progress) * (1.0 - progress);

    // テクスチャ読み込みを遅延（必要な場合のみ）
    float mod = 0.007;
    float trailMask = step(sdfTrail + mod, 0.0) + smoothstep(sdfTrail + mod, 0.0, 0.006) + smoothstep(sdfTrail + mod, 0.0, 0.007);
    float cursorMask = smoothstep(sdfCurrentCursor + 0.002, 0.0, 0.004) + smoothstep(sdfCurrentCursor, 0.0, easedProgress * lineLength);
    
    // 早期リターン判定
    if (trailMask < 0.001 && cursorMask < 0.001) {
        fragColor = texture(iChannel0, fragCoord / resXY);
        return;
    }
    
    // トレイル描画の最適化（mix呼び出しを削減）
    vec4 baseColor = texture(iChannel0, fragCoord / resXY);
    float trailBlend1 = smoothstep(0.0, sdfTrail + mod, 0.007);
    float trailBlend2 = smoothstep(0.0, sdfTrail + mod, 0.006);
    float insideTrail = step(sdfTrail + mod, 0.0);
    
    vec4 trail = mix(baseColor, TRAIL_COLOR_ACCENT, trailBlend1);
    trail = mix(trail, TRAIL_COLOR, trailBlend2 + insideTrail);
    
    // カーソル描画
    float cursorBlend = smoothstep(0.0, sdfCurrentCursor + 0.002, 0.004);
	trail = mix(trail, vec4(0.0, 0.0, 0.0, 1.0), cursorBlend);  // 黒色に変更
    
    fragColor = mix(trail, baseColor, 1.0 - smoothstep(0.0, sdfCurrentCursor, easedProgress * lineLength));
}
