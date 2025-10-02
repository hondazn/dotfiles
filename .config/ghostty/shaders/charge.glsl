float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// ハッシュ関数
float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

float hash2D(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

// 重力エフェクトのパラメータ
const float GRAVITY_WELL_DEPTH = 0.025;     // 井戸の深さ
const float GRAVITY_RADIUS = 0.08;          // 重力の影響範囲
const int GRID_RINGS = 8;                   // グリッドの同心円数
const int GRID_SPOKES = 16;                 // グリッドの放射線数
const float GRID_WIDTH = 0.0004;            // グリッド線の太さ

// パーティクル（直線落下）
const int PARTICLE_COUNT = 20;              // パーティクル数
const float PARTICLE_SIZE = 0.0012;         // パーティクルサイズ
const float INFALL_SPEED = 0.02;            // 基本落下速度
const float ACCELERATION_FACTOR = 2.0;      // 加速度係数

// 重力源コア
const float CORE_SIZE = 0.020;              // コアサイズ
const float CORE_PULSE_SPEED = 5.0;         // コアの脈動速度

// 降着ディスク
const int ACCRETION_PARTICLES = 5;         // 降着パーティクル数
const float ACCRETION_SPEED = 0.050;        // 落下速度（速め）

// エフェクトの段階的な強化
const float STAGE1_TIME = 2.0;              // 軽い重力
const float STAGE2_TIME = 5.0;              // 中程度の重力
const float FADE_IN_TIME = 0.3;

// 透明度調整
const float PARTICLE_OPACITY = 0.8;         // 通常パーティクルの透明度（0.0-1.0）
const float ACCRETION_OPACITY = 1.0;        // 降着パーティクルの透明度（0.0-1.0）
const float CORE_OPACITY = 0.75;             // コアの透明度（0.0-2.0）
const float WAVE_OPACITY = 1.0;             // 重力波の透明度（0.0-1.0）
const float OVERALL_OPACITY = 0.3;          // 全体の透明度（0.0-1.0）

// カーソル色反転
const float INVERT_SPEED = 5.0;             // 色反転の速度

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    float invResY = 1.0 / iResolution.y;
    vec2 resXY = iResolution.xy;
    vec2 vu = (fragCoord * 2.0 - resXY) * invResY;
    
    vec4 currentCursor = vec4(iCurrentCursor.xy * 2.0 - resXY, iCurrentCursor.zw * 2.0) * invResY;
    
    vec2 curHalfSize = currentCursor.zw * 0.5;
    vec2 centerCC = currentCursor.xy + vec2(curHalfSize.x, -curHalfSize.y);
    
    vec4 baseColor = texture(iChannel0, fragCoord / resXY);
    
    float timeSinceMove = iTime - iTimeCursorChange;
    
    // フェードインと段階的な強化
    float fadeIn = smoothstep(0.0, FADE_IN_TIME, timeSinceMove);
    float gravityStage1 = smoothstep(0.0, STAGE1_TIME, timeSinceMove);
    float gravityStage2 = smoothstep(STAGE1_TIME, STAGE2_TIME, timeSinceMove);
    float gravityStrength = 0.3 + gravityStage1 * 0.4 + gravityStage2 * 0.3;
    
    if (fadeIn < 0.01) {
        fragColor = baseColor;
        return;
    }
    
    float sdfCursor = getSdfRectangle(vu, centerCC, curHalfSize);
    
    vec2 toCenter = vu - centerCC;
    float distFromCenter = length(toCenter);
    float angleFromCenter = atan(toCenter.y, toCenter.x);
    
    float outsideMask = step(0.0, sdfCursor);
    float insideMask = 1.0 - outsideMask;
    float cursorRadius = length(curHalfSize);
    
    // 色設定
    vec3 gridColor = vec3(0.4, 0.6, 0.9);
    vec3 particleColor = vec3(0.6, 0.8, 1.0);
    vec3 coreColor = vec3(0.9, 0.95, 1.0);
    vec3 accretionColor = vec3(0.7, 0.85, 1.0);
    
    // コアの脈動
    float corePulse = 0.7 + 0.3 * sin(timeSinceMove * CORE_PULSE_SPEED);
    
    // === 重力井戸グリッド ===
    float grid = 0.0;
    
    // グリッド線を非表示
    
    // === 直線落下パーティクル（加速度あり） ===
    float allInfalling = 0.0;
    
    for (int i = 0; i < PARTICLE_COUNT; i++) {
        float particleIndex = float(i);
        
        // 各パーティクルは異なるタイミングでスタート
        float particlePhase = particleIndex / float(PARTICLE_COUNT);
        float particleSeed = particleIndex * 234.567;
        
        // 各パーティクルの開始位置（固定）
        float startAngle = hash(particleSeed * 0.123) * 6.28318530718;
        float startRadius = hash(particleSeed * 0.456) * (GRAVITY_RADIUS * 0.6) + GRAVITY_RADIUS * 0.4;
        
        // 落下時間（連続的、mod使わない）
        float cycleTime = startRadius / INFALL_SPEED;
        float particleTime = timeSinceMove + particlePhase * cycleTime;
        
        // 現在のサイクル内での位置
        float currentCycle = floor(particleTime / cycleTime);
        float fallProgress = fract(particleTime / cycleTime);
        
        // サイクルごとにシードを変えて位置を変化
        float cycleSeed = particleSeed + currentCycle * 123.456;
        startAngle = hash(cycleSeed * 0.789) * 6.28318530718;
        startRadius = hash(cycleSeed * 0.234) * (GRAVITY_RADIUS * 0.6) + GRAVITY_RADIUS * 0.4;
        
        // 加速度を考慮した現在位置
        float acceleratedProgress = fallProgress + fallProgress * fallProgress * ACCELERATION_FACTOR;
        acceleratedProgress = min(acceleratedProgress, 1.0);
        
        float currentRadius = startRadius * (1.0 - acceleratedProgress);
        
        // まっすぐ中心に向かう
        vec2 particlePos = centerCC + vec2(cos(startAngle), sin(startAngle)) * currentRadius;
        
        if (currentRadius > CORE_SIZE * 0.5) {
            float distToParticle = length(vu - particlePos);
            float particleGlow = smoothstep(PARTICLE_SIZE * 5.0, 0.0, distToParticle);
            
            // 中心に近づくほど明るく、速く動いている感じ
            float speedGlow = 1.0 + (1.0 - currentRadius / startRadius) * 2.0;
            
            // 速度に応じた尾を引く効果
            vec2 velocity = normalize(centerCC - particlePos);
            vec2 toPixel = vu - particlePos;
            float alongVelocity = dot(toPixel, velocity);
            
            // 後ろに尾を引く
            if (alongVelocity < 0.0 && alongVelocity > -0.008) {
                float tailIntensity = smoothstep(-0.008, 0.0, alongVelocity);
                float perpDist = length(toPixel - velocity * alongVelocity);
                float tailGlow = smoothstep(PARTICLE_SIZE * 2.0, 0.0, perpDist);
                particleGlow += tailGlow * tailIntensity * 0.5;
            }
            
            float flicker = 0.8 + hash(iTime * 8.0 + cycleSeed) * 0.2;
            
            allInfalling += particleGlow * speedGlow * flicker;
        }
    }
    
    allInfalling *= fadeIn;
    
    // === 降着パーティクル（高速直線落下） ===
    float allAccretion = 0.0;
    
    if (gravityStage1 > 0.1) {
        for (int a = 0; a < ACCRETION_PARTICLES; a++) {
            float accretionIndex = float(a);
            
            // 各パーティクルは異なるタイミングでスタート
            float accretionPhase = accretionIndex / float(ACCRETION_PARTICLES);
            float accretionSeed = accretionIndex * 345.678;
            
            // 各パーティクルの開始位置（固定）
            float startAngle = hash(accretionSeed * 0.234) * 6.28318530718;
            float startRadius = hash(accretionSeed * 0.567) * GRAVITY_RADIUS * 0.4 + GRAVITY_RADIUS * 0.6;
            
            // 落下時間（連続的）
            float cycleTime = startRadius / ACCRETION_SPEED;
            float accretionTime = timeSinceMove + accretionPhase * cycleTime;
            
            // 現在のサイクル内での位置
            float currentCycle = floor(accretionTime / cycleTime);
            float fallProgress = fract(accretionTime / cycleTime);
            
            // サイクルごとにシードを変えて位置を変化
            float cycleSeed = accretionSeed + currentCycle * 456.789;
            startAngle = hash(cycleSeed * 0.891) * 6.28318530718;
            startRadius = hash(cycleSeed * 0.123) * GRAVITY_RADIUS * 0.4 + GRAVITY_RADIUS * 0.6;
            
            // より強い加速度（降着は高速）
            float acceleratedProgress = fallProgress + fallProgress * fallProgress * ACCELERATION_FACTOR * 1.5;
            acceleratedProgress = min(acceleratedProgress, 1.0);
            
            // 現在の位置（まっすぐ中心へ）
            float currentRadius = startRadius * (1.0 - acceleratedProgress);
            
            if (currentRadius > CORE_SIZE * 0.5) {
                vec2 accretionPos = centerCC + vec2(cos(startAngle), sin(startAngle)) * currentRadius;
                
                float distToAccretion = length(vu - accretionPos);
                float accretionGlow = smoothstep(PARTICLE_SIZE * 4.0, 0.0, distToAccretion);
                
                // 中心に近づくほど非常に明るく
                float intensity = 1.0 + (1.0 - currentRadius / startRadius) * 3.0;
                float flicker = 0.7 + hash(iTime * 12.0 + cycleSeed) * 0.3;
                
                // 速度による尾（より長く）
                vec2 velocity = normalize(centerCC - accretionPos);
                vec2 toPixel = vu - accretionPos;
                float alongVelocity = dot(toPixel, velocity);
                
                if (alongVelocity < 0.0 && alongVelocity > -0.012) {
                    float tailIntensity = smoothstep(-0.012, 0.0, alongVelocity);
                    float perpDist = length(toPixel - velocity * alongVelocity);
                    float tailGlow = smoothstep(PARTICLE_SIZE * 2.5, 0.0, perpDist);
                    accretionGlow += tailGlow * tailIntensity * 0.7;
                }
                
                allAccretion += accretionGlow * intensity * flicker;
            }
        }
        
        allAccretion *= gravityStage1 * fadeIn;
    }
    
    // === 重力源コア ===
    float core = 0.0;
    
    if (distFromCenter < CORE_SIZE * 3.0) {
        core = smoothstep(CORE_SIZE * 3.0, CORE_SIZE * 0.5, distFromCenter) * corePulse;
    }
    
    core *= fadeIn;
    
    // === 重力波（時々放出） ===
    float waves = 0.0;
	float waveInterval = 1.5;
    
    if (gravityStage2 > 0.5) {
        float waveTime = mod(timeSinceMove, waveInterval);
        float waveRadius = cursorRadius * 1.5 + waveTime * 0.03;
        
        float distToWave = abs(distFromCenter - waveRadius);
        float waveIntensity = smoothstep(0.003, 0.0, distToWave);
        float waveFade = 1.0 - smoothstep(0.0, waveInterval * 0.8, waveTime);
        
        waves = waveIntensity * waveFade * gravityStage2;
    }
    
    // === 全エフェクトの合成 ===
    float totalEffect = allInfalling * PARTICLE_OPACITY + allAccretion * ACCRETION_OPACITY + core * CORE_OPACITY + waves * WAVE_OPACITY;
    
    // 色のブレンド
    vec3 finalColor = gridColor;
    finalColor = mix(finalColor, particleColor, smoothstep(0.2, 0.8, allInfalling));
    finalColor = mix(finalColor, accretionColor, smoothstep(0.3, 1.0, allAccretion));
    finalColor = mix(finalColor, coreColor, smoothstep(0.5, 1.5, core));
    
    vec4 effectColor = vec4(finalColor, min(totalEffect, 1.0) * 0.7);
    vec4 result = mix(baseColor, effectColor, min(totalEffect * OVERALL_OPACITY, 0.95));

	    // カーソル内部は色を反転（スムーズに点滅、中間は素早く通過）
    // 重力波の周期と同期
    float blinkSpeed = 6.28318530718 / waveInterval;  // 2π / 周期
    float t = (sin(timeSinceMove * blinkSpeed) * 0.5 + 0.5) * fadeIn;  // 0.0～1.0で滑らかに変化
    // S字カーブで中間を素早く通過（0と1付近でゆっくり、0.5付近で速く）
    float invertAmount = t < 0.5 ? pow(t * 2.0, 2.0) * 0.5 : 1.0 - pow((1.0 - t) * 2.0, 2.0) * 0.5;
    vec4 invertedCursor = vec4(1.0 - baseColor.rgb, baseColor.a);
    vec4 cursorWithInvert = mix(baseColor, invertedCursor, invertAmount);
    
    // コントラスト強調（カーソル領域のみ）
    const float CONTRAST = 1.8;  // コントラスト係数（1.0が元のまま、大きいほど強調）
    vec3 contrastedColor = (cursorWithInvert.rgb - 0.5) * CONTRAST + 0.5;
    contrastedColor = clamp(contrastedColor, 0.0, 1.0);
    cursorWithInvert.rgb = contrastedColor;
    
    result = mix(result, cursorWithInvert, insideMask);
    
    fragColor = result;
}
