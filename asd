<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>ZT Shooter | Простое подключение через ZeroTier</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            user-select: none;
        }
        body {
            background: #0a0a1a;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            font-family: 'Courier New', monospace;
            overflow: hidden;
        }
        canvas {
            display: block;
            box-shadow: 0 0 30px rgba(0, 255, 255, 0.3);
            border-radius: 12px;
            cursor: crosshair;
        }
        .ui {
            position: fixed;
            top: 20px;
            left: 20px;
            background: rgba(0,0,0,0.7);
            padding: 10px 18px;
            border-radius: 12px;
            backdrop-filter: blur(8px);
            border-left: 4px solid #33aaff;
            color: #33aaff;
            font-weight: bold;
            z-index: 10;
        }
        .ui2 {
            position: fixed;
            top: 20px;
            right: 20px;
            background: rgba(0,0,0,0.7);
            padding: 10px 18px;
            border-radius: 12px;
            backdrop-filter: blur(8px);
            border-right: 4px solid #ffaa33;
            color: #ffaa33;
            text-align: right;
            font-weight: bold;
            z-index: 10;
        }
        .scoreboard {
            position: fixed;
            top: 100px;
            left: 20px;
            background: rgba(0,0,0,0.6);
            padding: 8px 16px;
            border-radius: 8px;
            color: white;
            font-size: 14px;
            font-family: monospace;
            z-index: 10;
        }
        .connection-panel {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: rgba(0,0,0,0.95);
            backdrop-filter: blur(16px);
            padding: 20px;
            border-radius: 20px;
            z-index: 30;
            border: 2px solid #33aaff;
            font-family: monospace;
            width: 600px;
            max-width: 90vw;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 0 50px rgba(0,0,0,0.8);
        }
        .step {
            border: 1px solid #33aaff;
            border-radius: 12px;
            padding: 12px;
            margin-bottom: 15px;
        }
        .step-title {
            color: #88ff88;
            font-weight: bold;
            margin-bottom: 10px;
            font-size: 14px;
        }
        textarea, input {
            background: #1a1a2a;
            border: 1px solid #33aaff;
            padding: 10px;
            color: #0ff;
            font-family: monospace;
            font-size: 12px;
            border-radius: 8px;
            outline: none;
            width: 100%;
            resize: vertical;
        }
        button {
            background: #33aaff;
            border: none;
            padding: 8px 16px;
            border-radius: 30px;
            font-weight: bold;
            cursor: pointer;
            font-family: monospace;
            transition: 0.2s;
            margin: 5px 5px 0 0;
        }
        button:hover {
            background: #ffaa33;
        }
        .status {
            position: fixed;
            bottom: 30px;
            left: 50%;
            transform: translateX(-50%);
            background: rgba(0,0,0,0.7);
            padding: 5px 15px;
            border-radius: 20px;
            color: #ffaa66;
            font-size: 12px;
            z-index: 30;
        }
        .controls-info {
            position: fixed;
            bottom: 20px;
            left: 20px;
            color: #aaa;
            background: rgba(0,0,0,0.5);
            padding: 6px 12px;
            border-radius: 8px;
            font-size: 11px;
            backdrop-filter: blur(4px);
            z-index: 10;
        }
        .restart-btn {
            position: fixed;
            bottom: 30px;
            right: 30px;
            background: #ff3366;
            border: none;
            color: white;
            padding: 10px 18px;
            border-radius: 40px;
            font-weight: bold;
            cursor: pointer;
            z-index: 20;
        }
        .hidden { display: none; }
        .waiting-spinner {
            display: inline-block;
            width: 16px;
            height: 16px;
            border: 2px solid #33aaff;
            border-top-color: transparent;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
            margin-left: 8px;
            vertical-align: middle;
        }
        @keyframes spin { to { transform: rotate(360deg); } }
        .ip-row {
            background: #000;
            padding: 8px;
            border-radius: 12px;
            margin-bottom: 15px;
            text-align: center;
            font-family: monospace;
            color: #0f0;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="ui">
        🔵 ВЫ: ❤️ <span id="p1Health">100</span>% &nbsp;| 🔫 <span id="p1Ammo">30</span>
    </div>
    <div class="ui2">
        🟠 НАПАРНИК: ❤️ <span id="p2Health">100</span>% &nbsp;| 🔫 <span id="p2Ammo">30</span>
    </div>
    <div class="scoreboard">
        🤖 УБИЙСТВ: <span id="score">0</span> | ВОЛНА: <span id="wave">1</span>
    </div>
    <div class="connection-panel" id="connectionPanel">
        <div class="ip-row" id="ipDisplay">🔍 Определяю IP...</div>

        <div class="step">
            <div class="step-title">🔥 ХОСТ (создатель)</div>
            <button id="createOfferBtn">1. Создать Offer</button>
            <div id="hostOfferArea" style="margin-top:10px; display:none;">
                <textarea id="offerOutput" rows="4" readonly placeholder="Offer появится здесь"></textarea>
                <button id="copyOfferBtn">Копировать Offer</button>
            </div>
            <div id="hostAnswerArea" style="margin-top:10px; display:none;">
                <div class="step-title" style="margin-top:5px;">2. Вставьте Answer от друга:</div>
                <textarea id="answerInput" rows="4" placeholder="Вставьте сюда Answer..."></textarea>
                <button id="submitAnswerBtn">✅ Подтвердить Answer</button>
            </div>
        </div>

        <div class="step">
            <div class="step-title">🔗 КЛИЕНТ (подключающийся)</div>
            <textarea id="offerInput" rows="4" placeholder="Вставьте Offer от хоста..."></textarea>
            <button id="generateAnswerBtn">2. Ответить (создать Answer)</button>
            <div id="clientAnswerArea" style="margin-top:10px; display:none;">
                <textarea id="answerOutput" rows="4" readonly placeholder="Answer появится здесь"></textarea>
                <button id="copyAnswerBtn">Копировать Answer</button>
            </div>
        </div>

        <div style="font-size:11px; color:#aaa; text-align:center; margin-top:10px;">
            ✅ Убедитесь, что оба в одной сети ZeroTier.<br>
            📋 Копируйте и передавайте данные через любой мессенджер.
        </div>
    </div>
    <div class="status" id="status">Не подключено</div>
    <div class="controls-info">
        🎮 WASD / Стрелки — движение | F / . (точка) — стрельба | R — перезарядка
    </div>
    <button class="restart-btn" id="restartBtn">🔄 НОВАЯ ИГРА</button>

    <canvas id="gameCanvas" width="1200" height="700" style="width:100%; height:auto; max-width:1400px; aspect-ratio:1200/700;"></canvas>

    <script>
        // === CANVAS ===
        const canvas = document.getElementById('gameCanvas');
        const ctx = canvas.getContext('2d');
        const width = 1200, height = 700;
        canvas.width = width; canvas.height = height;

        // === ИГРОВЫЕ ПАРАМЕТРЫ ===
        let gameRunning = true;
        let wave = 1;
        let score = 0;
        let enemies = [];
        let walls = [];
        let healthPacks = [];

        let localPlayer = {
            id: null, x: width/2 - 100, y: height/2, radius: 16, health: 100, maxHealth: 100,
            ammo: 30, maxAmmo: 30, reloadTimer: 0, shootCooldown: 0, invincible: 0, color: '#33aaff'
        };
        let remotePlayer = {
            x: width/2 + 100, y: height/2, radius: 16, health: 100, ammo: 30, color: '#ffaa33', invincible: 0
        };
        let bullets = [];
        let enemyBullets = [];

        // Сеть
        let peerConnection = null;
        let dataChannel = null;
        let gameStarted = false;
        let isHost = false;
        let lastSend = 0;

        // Управление
        const keys = { w: false, s: false, a: false, d: false, up: false, down: false, left: false, right: false };
        let shoot1 = false, shoot2 = false;

        // === ФИЗИКА ===
        function createWalls() {
            walls = [
                { x: 300, y: 200, w: 80, h: 80 }, { x: 850, y: 500, w: 90, h: 70 },
                { x: 550, y: 550, w: 100, h: 60 }, { x: 100, y: 450, w: 70, h: 100 },
                { x: 950, y: 120, w: 70, h: 90 }, { x: 500, y: 80, w: 90, h: 70 },
                { x: 750, y: 320, w: 80, h: 80 }, { x: 200, y: 620, w: 100, h: 50 },
                { x: 1050, y: 550, w: 70, h: 80 }, { x: width/2-40, y: height/2-40, w: 80, h: 80 }
            ];
        }
        createWalls();

        function collideCircleRect(cx, cy, r, rect) {
            let cx2 = Math.max(rect.x, Math.min(cx, rect.x+rect.w));
            let cy2 = Math.max(rect.y, Math.min(cy, rect.y+rect.h));
            let dx = cx-cx2, dy = cy-cy2;
            return dx*dx+dy*dy < r*r;
        }

        function resolveCollision(obj, r) {
            for (let w of walls) {
                if (collideCircleRect(obj.x, obj.y, r, w)) {
                    let left = obj.x+r - w.x, right = w.x+w.w - (obj.x-r);
                    let top = obj.y+r - w.y, bottom = w.y+w.h - (obj.y-r);
                    let min = Math.min(left,right,top,bottom);
                    if (min===left) obj.x = w.x - r;
                    else if (min===right) obj.x = w.x + w.w + r;
                    else if (min===top) obj.y = w.y - r;
                    else obj.y = w.y + w.h + r;
                }
            }
            obj.x = Math.max(r, Math.min(width-r, obj.x));
            obj.y = Math.max(r, Math.min(height-r, obj.y));
        }

        // === ВРАГИ ===
        class Enemy {
            constructor(x,y) {
                this.x=x; this.y=y; this.r=16; this.health=40; this.maxHealth=40;
                this.speed=1.1; this.shootCd=Math.floor(Math.random()*30);
            }
            update(tx, ty) {
                let dx=tx-this.x, dy=ty-this.y, dist=Math.hypot(dx,dy);
                if(dist>0.1) {
                    let move=Math.min(this.speed, dist-40);
                    this.x+=dx/dist*move; this.y+=dy/dist*move;
                }
                resolveCollision(this, this.r);
                if(this.shootCd<=0) {
                    let ang=Math.atan2(ty-this.y, tx-this.x);
                    enemyBullets.push({x:this.x,y:this.y, vx:Math.cos(ang)*5, vy:Math.sin(ang)*5, damage:12});
                    this.shootCd=45;
                } else this.shootCd--;
            }
            draw() {
                ctx.beginPath(); ctx.arc(this.x,this.y,this.r,0,Math.PI*2);
                ctx.fillStyle="#ff3366"; ctx.fill(); ctx.strokeStyle="#fff"; ctx.stroke();
                let hpP=this.health/this.maxHealth;
                ctx.fillStyle="#f00"; ctx.fillRect(this.x-15,this.y-18,30,5);
                ctx.fillStyle="#0f0"; ctx.fillRect(this.x-15,this.y-18,30*hpP,5);
            }
        }

        function spawnWave() {
            enemies = [];
            let count = Math.min(3+wave*2, 18);
            for(let i=0;i<count;i++) {
                let side=Math.floor(Math.random()*4), x,y;
                if(side===0) { x=50+Math.random()*200; y=50+Math.random()*(height-100); }
                else if(side===1) { x=width-50-Math.random()*200; y=50+Math.random()*(height-100); }
                else if(side===2) { x=50+Math.random()*(width-100); y=50; }
                else { x=50+Math.random()*(width-100); y=height-50; }
                if(Math.hypot(x-localPlayer.x,y-localPlayer.y)<100) x+=50;
                enemies.push(new Enemy(x,y));
            }
        }

        // === ОБНОВЛЕНИЕ ИГРЫ ===
        function updateGame() {
            if(!gameStarted) return;

            // Движение
            let mx=0, my=0;
            if(keys.w) my-=1; if(keys.s) my+=1; if(keys.a) mx-=1; if(keys.d) mx+=1;
            if(keys.up) my-=1; if(keys.down) my+=1; if(keys.left) mx-=1; if(keys.right) mx+=1;
            if(mx||my) { let len=Math.hypot(mx,my); mx/=len; my/=len; }
            localPlayer.x += mx*5; localPlayer.y += my*5;
            resolveCollision(localPlayer, localPlayer.radius);

            // Стрельба
            if(localPlayer.reloadTimer>0) localPlayer.reloadTimer--;
            if(localPlayer.shootCooldown>0) localPlayer.shootCooldown--;
            let shooting = (shoot1 || shoot2);
            if(shooting && localPlayer.shootCooldown===0 && localPlayer.ammo>0 && localPlayer.reloadTimer===0) {
                let closest=null, minD=Infinity;
                for(let e of enemies) { let d=Math.hypot(e.x-localPlayer.x, e.y-localPlayer.y); if(d<minD) { minD=d; closest=e; } }
                let ang = closest ? Math.atan2(closest.y-localPlayer.y, closest.x-localPlayer.x) : Math.atan2(remotePlayer.y-localPlayer.y, remotePlayer.x-localPlayer.x);
                bullets.push({x:localPlayer.x, y:localPlayer.y, vx:Math.cos(ang)*11, vy:Math.sin(ang)*11, damage:22});
                localPlayer.ammo--;
                localPlayer.shootCooldown=10;
            }
            if(shooting && localPlayer.ammo===0 && localPlayer.reloadTimer===0) localPlayer.reloadTimer=40;

            // Пули
            for(let i=0;i<bullets.length;i++) {
                let b=bullets[i];
                b.x+=b.vx; b.y+=b.vy;
                if(b.x<0||b.x>width||b.y<0||b.y>height) { bullets.splice(i,1); i--; continue; }
                let hit=false;
                for(let w of walls) if(b.x>w.x && b.x<w.x+w.w && b.y>w.y && b.y<w.y+w.h) { hit=true; break; }
                if(hit) { bullets.splice(i,1); i--; continue; }
                for(let j=0;j<enemies.length;j++) {
                    let e=enemies[j];
                    if(Math.hypot(b.x-e.x, b.y-e.y)<e.r) {
                        e.health-=b.damage;
                        if(e.health<=0) {
                            enemies.splice(j,1); score++;
                            document.getElementById('score').innerText=score;
                            if(Math.random()<0.2) healthPacks.push({x:e.x, y:e.y, r:8});
                        }
                        bullets.splice(i,1); i--; hit=true; break;
                    }
                }
                if(hit) continue;
            }

            // Вражеские пули
            for(let i=0;i<enemyBullets.length;i++) {
                let b=enemyBullets[i];
                b.x+=b.vx; b.y+=b.vy;
                if(b.x<0||b.x>width||b.y<0||b.y>height) { enemyBullets.splice(i,1); i--; continue; }
                for(let w of walls) if(b.x>w.x && b.x<w.x+w.w && b.y>w.y && b.y<w.y+w.h) { enemyBullets.splice(i,1); i--; break; }
                if(i<0) continue;
                if(Math.hypot(b.x-localPlayer.x, b.y-localPlayer.y)<localPlayer.radius && localPlayer.invincible<=0) {
                    localPlayer.health-=b.damage;
                    localPlayer.invincible=20;
                    if(localPlayer.health<=0) gameRunning=false;
                    enemyBullets.splice(i,1); i--;
                }
            }
            if(localPlayer.invincible>0) localPlayer.invincible--;

            // Движение врагов
            for(let e of enemies) {
                let target = (localPlayer.health>0) ? localPlayer : remotePlayer;
                if(remotePlayer.health<=0) target=localPlayer;
                e.update(target.x, target.y);
            }

            // Хилки
            for(let i=0;i<healthPacks.length;i++) {
                let h=healthPacks[i];
                if(Math.hypot(localPlayer.x-h.x, localPlayer.y-h.y)<localPlayer.radius+8) {
                    localPlayer.health=Math.min(localPlayer.maxHealth, localPlayer.health+25);
                    healthPacks.splice(i,1); i--;
                }
            }

            // Волны
            if(enemies.length===0) {
                wave++;
                document.getElementById('wave').innerText=wave;
                localPlayer.health=Math.min(localPlayer.maxHealth, localPlayer.health+20);
                spawnWave();
            }

            // Отправка состояния
            if(dataChannel && dataChannel.readyState==='open') {
                let now=Date.now();
                if(now-lastSend>30) {
                    lastSend=now;
                    dataChannel.send(JSON.stringify({
                        x:localPlayer.x, y:localPlayer.y, health:localPlayer.health, ammo:localPlayer.ammo, reload:localPlayer.reloadTimer
                    }));
                }
            }
        }

        function draw() {
            ctx.clearRect(0,0,width,height);
            for(let w of walls) {
                ctx.fillStyle="#1a2a3a"; ctx.fillRect(w.x,w.y,w.w,w.h);
                ctx.strokeStyle="#0ff"; ctx.strokeRect(w.x,w.y,w.w,w.h);
            }
            for(let h of healthPacks) {
                ctx.beginPath(); ctx.arc(h.x,h.y,8,0,Math.PI*2);
                ctx.fillStyle="#88ff88"; ctx.fill();
                ctx.fillStyle="white"; ctx.fillText("+",h.x-4,h.y+5);
            }
            for(let b of bullets) { ctx.beginPath(); ctx.arc(b.x,b.y,4,0,Math.PI*2); ctx.fillStyle="#ffff66"; ctx.fill(); }
            for(let b of enemyBullets) { ctx.beginPath(); ctx.arc(b.x,b.y,5,0,Math.PI*2); ctx.fillStyle="#ff8866"; ctx.fill(); }
            for(let e of enemies) e.draw();

            ctx.shadowBlur=12;
            ctx.beginPath(); ctx.arc(localPlayer.x,localPlayer.y,localPlayer.radius,0,Math.PI*2);
            ctx.fillStyle=localPlayer.color; ctx.fill(); ctx.strokeStyle="white"; ctx.stroke();
            ctx.fillStyle="#fff"; ctx.font="bold 12px monospace";
            ctx.fillText("YOU",localPlayer.x-12,localPlayer.y-12);
            let hpP=localPlayer.health/localPlayer.maxHealth;
            ctx.fillStyle="#f00"; ctx.fillRect(localPlayer.x-18,localPlayer.y-22,36,5);
            ctx.fillStyle="#0f0"; ctx.fillRect(localPlayer.x-18,localPlayer.y-22,36*hpP,5);

            if(remotePlayer.health>0) {
                ctx.beginPath(); ctx.arc(remotePlayer.x,remotePlayer.y,remotePlayer.radius,0,Math.PI*2);
                ctx.fillStyle=remotePlayer.color; ctx.fill(); ctx.strokeStyle="white"; ctx.stroke();
                ctx.fillStyle="#fff"; ctx.fillText("FRIEND",remotePlayer.x-18,remotePlayer.y-12);
                let hpR=remotePlayer.health/100;
                ctx.fillStyle="#f00"; ctx.fillRect(remotePlayer.x-18,remotePlayer.y-22,36,5);
                ctx.fillStyle="#0f0"; ctx.fillRect(remotePlayer.x-18,remotePlayer.y-22,36*hpR,5);
            }
            ctx.shadowBlur=0;

            document.getElementById('p1Health').innerText=localPlayer.health;
            document.getElementById('p1Ammo').innerText=localPlayer.ammo;
            document.getElementById('p2Health').innerText=remotePlayer.health;
            document.getElementById('p2Ammo').innerText=remotePlayer.ammo;
            if(!gameRunning && gameStarted) {
                ctx.font="48px monospace"; ctx.fillStyle="#ff3366";
                ctx.fillText("GAME OVER",width/2-130,height/2);
            }
            if(!gameStarted) {
                ctx.font="28px monospace"; ctx.fillStyle="#aaaaff";
                ctx.fillText("Ожидание подключения...",width/2-150,height/2);
            }
        }

        // === СЕТЬ (WebRTC) ===
        const iceServers = [{ urls: 'stun:stun.l.google.com:19302' }];

        async function createOffer() {
            peerConnection = new RTCPeerConnection({ iceServers });
            dataChannel = peerConnection.createDataChannel("game");
            setupDataChannel(dataChannel);
            const offer = await peerConnection.createOffer();
            await peerConnection.setLocalDescription(offer);
            return peerConnection.localDescription.sdp;
        }

        async function handleOffer(offerSdp) {
            peerConnection = new RTCPeerConnection({ iceServers });
            peerConnection.ondatachannel = (event) => {
                dataChannel = event.channel;
                setupDataChannel(dataChannel);
            };
            await peerConnection.setRemoteDescription({ type: 'offer', sdp: offerSdp });
            const answer = await peerConnection.createAnswer();
            await peerConnection.setLocalDescription(answer);
            return peerConnection.localDescription.sdp;
        }

        async function handleAnswer(answerSdp) {
            await peerConnection.setRemoteDescription({ type: 'answer', sdp: answerSdp });
        }

        function setupDataChannel(channel) {
            channel.onopen = () => {
                document.getElementById('status').innerText = "✅ Соединение установлено!";
                document.getElementById('connectionPanel').classList.add('hidden');
                gameStarted = true;
                if(isHost) spawnWave();
            };
            channel.onmessage = (event) => {
                const data = JSON.parse(event.data);
                remotePlayer.x = data.x;
                remotePlayer.y = data.y;
                remotePlayer.health = data.health;
                remotePlayer.ammo = data.ammo;
                remotePlayer.reloadTimer = data.reload;
            };
            channel.onclose = () => {
                document.getElementById('status').innerText = "❌ Соединение потеряно";
                gameStarted = false;
            };
        }

        // === ОПРЕДЕЛЕНИЕ IP (через WebRTC) ===
        function detectLocalIPs() {
            const pc = new RTCPeerConnection({ iceServers: [] });
            pc.createDataChannel('');
            pc.createOffer().then(offer => pc.setLocalDescription(offer));
            const ips = new Set();
            pc.onicecandidate = (e) => {
                if (!e.candidate) return;
                const ipMatch = /([0-9]{1,3}\.){3}[0-9]{1,3}/.exec(e.candidate.candidate);
                if (ipMatch) ips.add(ipMatch[0]);
                document.getElementById('ipDisplay').innerHTML = `🌐 Ваши IP-адреса: ${Array.from(ips).join(', ')}`;
            };
            setTimeout(() => {
                if(ips.size===0) document.getElementById('ipDisplay').innerHTML = "⚠️ Не удалось определить IP. Проверьте разрешения.";
                pc.close();
            }, 2000);
        }

        // === УПРАВЛЕНИЕ ===
        function handleKeyboard() {
            window.addEventListener('keydown', (e) => {
                let k = e.code;
                if (k === 'KeyW') keys.w = true;
                if (k === 'KeyS') keys.s = true;
                if (k === 'KeyA') keys.a = true;
                if (k === 'KeyD') keys.d = true;
                if (k === 'KeyF') shoot1 = true;
                if (k === 'ArrowUp') keys.up = true;
                if (k === 'ArrowDown') keys.down = true;
                if (k === 'ArrowLeft') keys.left = true;
                if (k === 'ArrowRight') keys.right = true;
                if (k === 'Period' || k === 'Slash') shoot2 = true;
                if (k === 'KeyR' && gameStarted && localPlayer.reloadTimer===0 && localPlayer.ammo!==localPlayer.maxAmmo) localPlayer.reloadTimer=40;
                e.preventDefault();
            });
            window.addEventListener('keyup', (e) => {
                let k = e.code;
                if (k === 'KeyW') keys.w = false;
                if (k === 'KeyS') keys.s = false;
                if (k === 'KeyA') keys.a = false;
                if (k === 'KeyD') keys.d = false;
                if (k === 'KeyF') shoot1 = false;
                if (k === 'ArrowUp') keys.up = false;
                if (k === 'ArrowDown') keys.down = false;
                if (k === 'ArrowLeft') keys.left = false;
                if (k === 'ArrowRight') keys.right = false;
                if (k === 'Period' || k === 'Slash') shoot2 = false;
            });
        }

        function animate() {
            if(gameStarted) updateGame();
            draw();
            requestAnimationFrame(animate);
        }

        // === UI ===
        document.getElementById('createOfferBtn').onclick = async () => {
            isHost = true;
            localPlayer.id = 0; remotePlayer.id = 1;
            localPlayer.color = "#33aaff"; remotePlayer.color = "#ffaa33";
            document.getElementById('status').innerHTML = 'Создаю Offer...';
            const offer = await createOffer();
            document.getElementById('offerOutput').value = offer;
            document.getElementById('hostOfferArea').style.display = 'block';
            document.getElementById('hostAnswerArea').style.display = 'block';
            document.getElementById('status').innerText = "Offer создан. Передайте его другу и вставьте его Answer.";
        };
        document.getElementById('copyOfferBtn').onclick = () => {
            navigator.clipboard.writeText(document.getElementById('offerOutput').value);
            document.getElementById('status').innerText = "Offer скопирован!";
        };
        document.getElementById('submitAnswerBtn').onclick = async () => {
            const answer = document.getElementById('answerInput').value.trim();
            if(!answer) { document.getElementById('status').innerText = "Введите Answer!"; return; }
            await handleAnswer(answer);
            document.getElementById('status').innerHTML = 'Ожидание соединения... <span class="waiting-spinner"></span>';
        };
        document.getElementById('generateAnswerBtn').onclick = async () => {
            const offer = document.getElementById('offerInput').value.trim();
            if(!offer) { document.getElementById('status').innerText = "Введите Offer от хоста!"; return; }
            isHost = false;
            localPlayer.id = 1; remotePlayer.id = 0;
            localPlayer.color = "#ffaa33"; remotePlayer.color = "#33aaff";
            document.getElementById('status').innerHTML = 'Обработка...';
            const answer = await handleOffer(offer);
            document.getElementById('answerOutput').value = answer;
            document.getElementById('clientAnswerArea').style.display = 'block';
            document.getElementById('status').innerText = "Answer создан. Передайте его хосту.";
        };
        document.getElementById('copyAnswerBtn').onclick = () => {
            navigator.clipboard.writeText(document.getElementById('answerOutput').value);
            document.getElementById('status').innerText = "Answer скопирован!";
        };
        document.getElementById('restartBtn').onclick = () => location.reload();

        handleKeyboard();
        detectLocalIPs();
        localPlayer.x = width/2 - 100; localPlayer.y = height/2;
        remotePlayer.x = width/2 + 100; remotePlayer.y = height/2;
        animate();
    </script>
</body>
</html>
