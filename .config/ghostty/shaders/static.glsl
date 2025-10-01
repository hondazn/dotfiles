float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

const vec4 RIPPLE_COLOR = vec4(0.6, 0.8, 1.0, 1.0);

// 波紋のパラメータ
const float RIPPLE_SPEED = 0.06;        // 波紋の広がる速度
const float RIPPLE_INTERVAL = 1.2;      // 波紋の発生間隔（秒）
const float RIPPLE_WIDTH = 0.004;       // 波紋の太さ（細く）
const float RIPPLE_MAX_RADIUS = 0.06;   // 波紋の最大半径
const float RIPPLE_INTENSITY = 0.6;     // 波紋の明るさ
const int RIPPLE_COUNT = 1;             // 同時に表示する波紋の数

// フェードイン時間（秒）
const float FADE_IN_TIME = 0.5;
// フェードアウト時間（秒）
const float FADE_OUT_TIME = 0.3;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // 正規化
    float invResY = 1.0 / iResolution.y;
    vec2 resXY = iResolution.xy;
    vec2 vu = (fragCoord * 2.0 - resXY) * invResY;
    
    // カーソル情報の正規化
    vec4 currentCursor = vec4(iCurrentCursor.xy * 2.0 - resXY, iCurrentCursor.zw * 2.0) * invResY;
    
    // カーソル中心とサイズ
    vec2 curHalfSize = currentCursor.zw * 0.5;
    vec2 centerCC = currentCursor.xy + vec2(curHalfSize.x, -curHalfSize.y);
    
    // 基本のテクスチャ
    vec4 baseColor = texture(iChannel0, fragCoord / resXY);
    
    // カーソルが最後に動いてからの時間
    float timeSinceMove = iTime - iTimeCursorChange;
    
    // フェードアウト効果
    float fadeOut = smoothstep(0.0, FADE_OUT_TIME, timeSinceMove);
    
    // エフェクトがまだ開始していない場合は早期リターン
    if (fadeOut < 0.01) {
        fragColor = baseColor;
        return;
    }
    
    // SDF計算
    float sdfCursor = getSdfRectangle(vu, centerCC, curHalfSize);
    
    // フェードイン効果
    float fadeIn = smoothstep(FADE_OUT_TIME, FADE_OUT_TIME + FADE_IN_TIME, timeSinceMove);
    
    // 全体のフェード
    float totalFade = fadeOut * fadeIn;
    
    // カーソル中心からの距離
    float distFromCenter = length(vu - centerCC);
    
    // カーソル内部と外側
    float insideCursor = 1.0 - step(0.0, sdfCursor);
    float outsideMask = step(0.0, sdfCursor);
    
    // カーソルの「半径」（矩形なので対角線の半分）
    float cursorRadius = length(curHalfSize);
    
    // 波紋の周期に合わせたカーソルの点滅（blink）
    float blinkPhase = mod(timeSinceMove, RIPPLE_INTERVAL) / RIPPLE_INTERVAL;
    // 0.5秒ごとにオン/オフを切り替え（0〜0.5で表示、0.5〜1.0で透明）
    float cursorVisible = step(blinkPhase, 0.5);
    
    // 複数の波紋を合成
    float allRipples = 0.0;
    
    for (int i = 0; i < RIPPLE_COUNT; i++) {
        // 各波紋の時間オフセット
        float rippleTime = timeSinceMove - float(i) * RIPPLE_INTERVAL;
        
        if (rippleTime > 0.0) {
            // 波紋の周期（最大半径まで到達する時間）
            float rippleCycle = RIPPLE_MAX_RADIUS / RIPPLE_SPEED;
            
            // 波紋の時間を周期でループ
            float loopedTime = mod(rippleTime, rippleCycle);
            
            // 波紋の現在の半径
            float rippleRadius = cursorRadius + loopedTime * RIPPLE_SPEED;
            
            // この波紋の中心からの距離の差
            float distToRipple = abs(distFromCenter - rippleRadius);
            
            // 波紋のリング（滑らかなエッジ）
            float ripple = smoothstep(RIPPLE_WIDTH, 0.0, distToRipple);
            
            // 距離に応じてフェードアウト
            float distanceFade = 1.0 - smoothstep(cursorRadius, cursorRadius + RIPPLE_MAX_RADIUS, distFromCenter);
            
            // 波紋を加算
            allRipples += ripple * distanceFade;
        }
    }
    
    // カーソルの外側のみに波紋を適用
    allRipples *= outsideMask * RIPPLE_INTENSITY * totalFade;
    
    // カーソル内部の色反転点滅
    // 表示時は色を反転、非表示時は元の色のまま
    vec4 invertedColor = vec4(1.0 - baseColor.rgb, 1.0);
    vec4 cursorColor = mix(baseColor, invertedColor, insideCursor * cursorVisible * totalFade);
    
    // 最終カラー合成
    vec4 finalColor = mix(cursorColor, RIPPLE_COLOR, allRipples);
    
    fragColor = finalColor;
}
