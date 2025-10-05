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

float sdCurve(vec2 p, vec2 a, vec2 b, float curvature, out float h) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    float offset = curvature * sin(h * 3.14159);
    vec2 normal = normalize(vec2(ba.y, -ba.x));
    return length(pa - ba * h - normal * offset);
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
    float fadeOutTime = 0.13;
    float fadeIn = smoothstep(0.0, fadeInTime, elapsed);
    float fadeOut = 1.0 - smoothstep(duration - fadeOutTime, duration, elapsed);
    float fade = clamp(fadeIn * fadeOut, 0.0, 1.0);
    vec2 cursorPos = norm(iCurrentCursor.xy, 1.);
    vec2 vu = norm(fragCoord, 1.);
    vec2 cursorSize = norm(iCurrentCursor.zw, 0.);
    vec2 offsetFactor = vec2(-0.5, 0.5);
    vec2 cursorCenter = cursorPos - (cursorSize * offsetFactor);
    
    // === スラッシュエフェクト設定 ===
    const float TIME_MULTIPLIER = 2.0;
    const float SLASH_LENGTH = 0.20;
    const float CURVATURE = 0.01;
    
    // ランダムなスラッシュの角度を生成
    float randomSeed = iTimeCursorChange + dot(iCurrentCursor.xy, vec2(12.9898, 78.233));
    float randomAngle = hash11(randomSeed) * 6.283185;
    vec2 slashDir = vec2(cos(randomAngle), sin(randomAngle));
    
    // スラッシュのアニメーション
    float t = TIME_MULTIPLIER * elapsed;
    t = clamp(t, 0.0, 1.0);
    
    // カーソル位置を曲線が正しく通るように、始点と終点を補正
    vec2 normal = vec2(slashDir.y, -slashDir.x);
    vec2 curveOffset = normal * CURVATURE;
    vec2 baseStart = cursorCenter - slashDir * SLASH_LENGTH * 0.5;
    vec2 baseEnd = cursorCenter + slashDir * SLASH_LENGTH * 0.5;
    vec2 slashStart = baseStart - curveOffset;
    vec2 slashEnd = baseEnd - curveOffset;
    
    // 補正済みの始点と終点を使って、曲線までの距離を計算
    float h;
    float dist = sdCurve(vu, slashStart, slashEnd, CURVATURE, h);
    
    // 太さの変化：中央が太く、両端が細い
    float widthProfile = sin(h * 3.14159) * 1.5 + 0.3;
    
    // グロー効果
    float coreGlow = exp(-dist * 250.0 / widthProfile) * (1.0 - t * 0.4);
    float outerGlow = exp(-dist * 60.0 / widthProfile) * (1.0 - t * 0.7) * 0.5;
    
    float c0 = (coreGlow * 4.0 + outerGlow * 2.0);
    
    // === トゲトゲエフェクト（ビーム発射の予兆） ===
    float spikeGlow = 0.0;
    
    // スラッシュの終盤からトゲが出現
    float spikeStartTime = duration * 0.6;  // スラッシュの80%地点から
	float spikeDuration = 0.04;    // トゲの表示時間
    float spikeEndTime = spikeStartTime + spikeDuration;          // スラッシュの終了時まで
    
    if (elapsed > spikeStartTime && elapsed < spikeEndTime) {
        float spikeElapsed = elapsed - spikeStartTime;
        float spikeDuration = spikeEndTime - spikeStartTime;
        float spikeT = spikeElapsed / spikeDuration;
        
        // トゲの成長と消滅
        float spikeIntensity = sin(spikeT * 3.14159); // 0→1→0
        
        // 曲線に沿って複数のトゲを配置
        for (int i = 0; i < 6; i++) {
            float spikeH = float(i) / 5.0;
            
            // 根元付近のトゲはスキップ
            if (spikeH < 0.35) continue;
            
            // トゲの中心位置（スラッシュの軌跡上）
            vec2 spikeCenter = mix(slashStart, slashEnd, spikeH);
            vec2 curveNormal = normalize(vec2(slashDir.y, -slashDir.x));
            spikeCenter += curveNormal * CURVATURE * sin(spikeH * 3.14159);
            
            // トゲの主方向：ビームと同じ（位置によって変化）
            vec2 outwardDir = curveNormal;
            float forwardRatio = mix(0.2, 3.5, spikeH); // ビームと同じ角度
            vec2 spikeMainDir = normalize(outwardDir + slashDir * forwardRatio);
            
            // 収束点（外側の1点）
            float maxSpikeLength = 0.025;
            float spikeLength = maxSpikeLength * spikeIntensity;
            vec2 convergencePoint = spikeCenter + spikeMainDir * spikeLength;
            
            // 漏斗状に広がるトゲを複数本描画
            const int NUM_SPIKE_LINES = 5;
            for (int j = 0; j < NUM_SPIKE_LINES; j++) {
                // スラッシュ側の根本のオフセット（開始側で広く、進行方向で細く）
                float offsetRatio = (float(j) / float(NUM_SPIKE_LINES - 1) - 0.5); // -0.5 to 0.5
                float spreadWidth = 0.025 * (1.0 - spikeH); // 開始側で広く、終了側で細く
                vec2 rootOffset = slashDir * offsetRatio * spreadWidth;
                vec2 spikeStart = spikeCenter + rootOffset;
                
                // トゲの終点（外側の1点に収束）
                vec2 spikeEnd = convergencePoint;
                
                // トゲまでの距離と位置パラメータ
                vec2 pa = vu - spikeStart;
                vec2 ba = spikeEnd - spikeStart;
                float spikeHParam = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
                float spikeDist = length(pa - ba * spikeHParam);
                
                // トゲの太さ（根本で太く、先端で細く）
                float spikeWidth = 1.0 - spikeHParam * 0.8; // 根本:1.0 → 先端:0.2
                
                // トゲのグロー（太さを考慮）
                float spikeCore = exp(-spikeDist * 250.0 / spikeWidth) * spikeIntensity * 2.5;
                
                spikeGlow += spikeCore;
            }
        }
    }
    
    // === 弾けるビームエフェクト（トゲの後に表示） ===
    float beamGlow = 0.0;
    
    // トゲが消える頃にビームが発生
    float beamStartTime = duration - 0.08; // スラッシュの終了時間
    float beamDuration = 0.05; // ビームの表示時間
    float beamEndTime = beamStartTime + beamDuration;
    
    if (elapsed > beamStartTime && elapsed < beamEndTime) {
        float beamElapsed = elapsed - beamStartTime;
        float beamT = beamElapsed / beamDuration;
        
        // ビーム用のフェード
        float beamFade = smoothstep(0.0, 0.05, beamElapsed) * 
                         (1.0 - smoothstep(beamDuration * 0.7, beamDuration, beamElapsed));
        
        // 曲線に沿って複数のビームを配置
        for (int i = 0; i < 6; i++) {
            // 曲線上の位置
            float beamH = float(i) / 5.0;
            
            // 根元付近のビームはスキップ
            if (beamH < 0.1) continue;
            
            // ビームの発生ポイントを計算（曲線から外側にオフセット）
            vec2 beamOrigin = mix(slashStart, slashEnd, beamH);
            vec2 curveNormal = normalize(vec2(slashDir.y, -slashDir.x));
            beamOrigin += curveNormal * CURVATURE * sin(beamH * 3.14159);
            beamOrigin += curveNormal * 0.0125; // 外側に少しオフセット（近づける）
            
            // ビームごとのランダム値（長さのバリエーション用）
            float beamSeed = randomSeed * 100.0 + float(i) * 50.0;
            vec2 random = hash21(beamSeed);
            
            // ビームの方向：位置によって角度が変化
            // 開始地点ではより外側に、終了地点ではより進行方向に
            vec2 outwardDir = normalize(vec2(slashDir.y, -slashDir.x)); // 曲線の外側方向
            float forwardRatio = mix(0.05, 3.5, beamH); // 開始:0.2(外側寄り) → 終了:3.5(進行方向寄り)
            vec2 beamDir = normalize(outwardDir + slashDir * forwardRatio);
            
            // ビームのアニメーション（遅延付き）
            float beamDelay = random.y * 0.3;
            float localT = clamp((beamT - beamDelay) / (1.0 - beamDelay), 0.0, 1.0);
            
            // ビームの長さ
            float maxLength = 0.1;
            vec2 beamEnd = beamOrigin + beamDir * maxLength * localT;
            
            // ビームまでの距離を計算(線分として)
            vec2 pa = vu - beamOrigin;
            vec2 ba = beamEnd - beamOrigin;
            float beamHParam = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
            float beamDist = length(pa - ba * beamHParam);
            
            // ビームの太さ(両端が鋭く、真ん中が膨らむ)
			float beamWidth = pow(sin(beamHParam * 3.14159), 3.0) * 0.98 + 0.02;
            
            // ビームのグロー（太く明るく）
            float intensity = (1.0 - localT * 0.3) * localT;
            float coreBeam = exp(-beamDist * 80.0 / beamWidth) * intensity * 5.0;
            
            beamGlow += coreBeam * beamFade;
        }
    }
    
    // スラッシュ、トゲ、ビームを別々に合成
    vec3 slashColor = c0 * base_color * fade;
    vec3 spikeColor = spikeGlow * base_color * fade; // トゲもスラッシュと同じフェードを適用
    vec3 beamColor = beamGlow * base_color;
    
    // 色の合成
    vec3 rgb = slashColor + spikeColor + beamColor;
    rgb += hash33(vec3(fragCoord, iTime * 256.)) / 1024.;
    rgb = pow(rgb, vec3(0.4545));
    
    // 加算合成
    float slashMask = clamp(c0 * 0.15, 0.0, 1.0) * fade;
    float spikeMask = clamp(spikeGlow * 0.15, 0.0, 1.0) * fade;
    float beamMask = clamp(beamGlow * 0.15, 0.0, 1.0);
    vec4 newColor = fragColor + vec4(rgb * (slashMask + spikeMask + beamMask), 0.0);
    
    fragColor = min(newColor, 1.0);
}
