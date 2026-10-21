Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[void][System.Windows.Forms.MessageBox]::Show(
    'Hello im fun!!',
    'FUN',
    [System.Windows.Forms.MessageBoxButtons]::OK,
    [System.Windows.Forms.MessageBoxIcon]::Information
)

$choice = [System.Windows.Forms.MessageBox]::Show(
    'want to have some fun pls',
    'FUN',
    [System.Windows.Forms.MessageBoxButtons]::YesNo,
    [System.Windows.Forms.MessageBoxIcon]::Question
)

if ($choice -eq [System.Windows.Forms.DialogResult]::Yes) {
    $soundChoice = [System.Windows.Forms.MessageBox]::Show(
        'Do you want to hear fireworks sounds?',
        'Geluid?',
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )
    $player = $null
    $playSounds = $soundChoice -eq [System.Windows.Forms.DialogResult]::Yes
    if ($playSounds) {
        Add-Type -AssemblyName PresentationCore
        $soundPath = Join-Path $PSScriptRoot 'fireworks.mp3'
        if (Test-Path -LiteralPath $soundPath) {
            $player = New-Object System.Windows.Media.MediaPlayer
            $player.Volume = 0.65
            $player.Open([Uri]$soundPath)
            $player.Play()
        }
    }
    $fireworksSource = @"
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;

public class FunFireworksForm : Form
{
    private class Particle
    {
        public float X, Y, VX, VY, Life;
        public Color Color;
    }

    private class JamSplat
    {
        public float X, Y;
        public int Radius;
        public Color Color;
    }

    private readonly List<Particle> particles = new List<Particle>();
    private readonly List<JamSplat> jamSplats = new List<JamSplat>();
    private readonly Random random = new Random();
    private readonly Timer timer = new Timer();
    private int ticks = 0;
    private DateTime started;

    public void ShowFireworks() { ShowDialog(); }

    public FunFireworksForm()
    {
        FormBorderStyle = FormBorderStyle.None;
        WindowState = FormWindowState.Maximized;
        BackColor = Color.Black;
        TopMost = true;
        KeyPreview = true;
        DoubleBuffered = true;
        KeyDown += (s, e) => { if (e.KeyCode == Keys.Escape) Close(); };
        timer.Interval = 30;
        timer.Tick += (s, e) => {
            if ((DateTime.UtcNow - started).TotalSeconds >= 5) { Close(); return; }
            ticks++;
            if (ticks % 16 == 0) Burst(random.Next(80, Math.Max(81, ClientSize.Width - 80)), random.Next(80, Math.Max(81, ClientSize.Height / 2)));
            if (ticks % 24 == 0) AddJamSplat(random.Next(60, Math.Max(61, ClientSize.Width - 60)), random.Next(60, Math.Max(61, ClientSize.Height - 60)));
            for (int i = particles.Count - 1; i >= 0; i--) {
                Particle p = particles[i];
                p.X += p.VX; p.Y += p.VY; p.VY += 0.045f; p.Life -= 0.018f;
                if (p.Life <= 0) particles.RemoveAt(i);
            }
            Invalidate();
        };
        Shown += (s, e) => { started = DateTime.UtcNow; Burst(ClientSize.Width / 2, ClientSize.Height / 3); timer.Start(); };
        FormClosed += (s, e) => timer.Dispose();
    }

    private void Burst(int x, int y)
    {
        Color[] colors = { Color.HotPink, Color.DeepSkyBlue, Color.Gold, Color.Lime, Color.Violet, Color.OrangeRed };
        Color color = colors[random.Next(colors.Length)];
        for (int i = 0; i < 70; i++) {
            double angle = random.NextDouble() * Math.PI * 2;
            float speed = 1.5f + (float)random.NextDouble() * 5.0f;
            particles.Add(new Particle { X=x, Y=y, VX=(float)Math.Cos(angle)*speed, VY=(float)Math.Sin(angle)*speed, Life=0.7f+(float)random.NextDouble()*0.5f, Color=color });
        }
    }

    private void AddJamSplat(int x, int y)
    {
        Color[] jamColors = { Color.Firebrick, Color.DarkRed, Color.Crimson, Color.IndianRed };
        Color jamColor = jamColors[random.Next(jamColors.Length)];
        jamSplats.Add(new JamSplat { X=x, Y=y, Radius=20+random.Next(14), Color=jamColor });
        for (int i = 0; i < 14; i++) {
            double angle = random.NextDouble() * Math.PI * 2;
            float distance = 18 + (float)random.NextDouble() * 48;
            jamSplats.Add(new JamSplat { X=x+(float)Math.Cos(angle)*distance, Y=y+(float)Math.Sin(angle)*distance, Radius=4+random.Next(12), Color=jamColor });
        }
    }

    protected override void OnPaint(PaintEventArgs e)
    {
        base.OnPaint(e);
        e.Graphics.Clear(Color.Black);
        foreach (JamSplat splat in jamSplats) {
            using (Brush brush = new SolidBrush(splat.Color))
                e.Graphics.FillEllipse(brush, splat.X-splat.Radius, splat.Y-splat.Radius, splat.Radius*2, splat.Radius*2);
        }

        foreach (Particle p in particles) {
            int alpha = Math.Max(0, Math.Min(255, (int)(p.Life * 300)));
            using (Brush brush = new SolidBrush(Color.FromArgb(alpha, p.Color)))
                e.Graphics.FillEllipse(brush, p.X, p.Y, 5, 5);
        }
    }
}
"@;
    Add-Type -TypeDefinition $fireworksSource -ReferencedAssemblies @('System.Windows.Forms', 'System.Drawing');
    $form = New-Object FunFireworksForm;
    $form.ShowFireworks();
    if ($player) { $player.Stop(); $player.Close(); }
    [void][System.Windows.Forms.MessageBox]::Show(
        'hahaha it not going to be easy',
        'FUN',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )
    if ($playSounds) {
        $boomPath = Join-Path $PSScriptRoot 'boom.mp3'
        if (Test-Path -LiteralPath $boomPath) {
            $boomPlayer = New-Object System.Windows.Media.MediaPlayer
            $boomPlayer.Volume = 0.8
            $boomPlayer.Open([Uri]$boomPath)
            $boomPlayer.Play()
            Start-Sleep -Milliseconds 1600
            $boomPlayer.Stop()
            $boomPlayer.Close()
        }
    }

    $locustUrl = 'https://www.youtube.com/watch?v=mXTYvRf3qew&autoplay=1'
    $edgePaths = @(
        (Join-Path ${env:ProgramFiles(x86)} 'Microsoft\Edge\Application\msedge.exe'),
        (Join-Path $env:ProgramFiles 'Microsoft\Edge\Application\msedge.exe'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\Edge\Application\msedge.exe')
    )
    $edgeExecutable = $edgePaths | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    if ($edgeExecutable) {
        $debugPort = Get-Random -Minimum 49152 -Maximum 65535
        $edgeProfile = Join-Path $env:TEMP ('FunLocust-' + [guid]::NewGuid().ToString('N'))
        $edgeSession = Start-Process -FilePath $edgeExecutable -ArgumentList @(
            '--kiosk', $locustUrl, '--edge-kiosk-type=fullscreen',
            "--remote-debugging-port=$debugPort", "--user-data-dir=$edgeProfile"
        ) -PassThru

        Start-Sleep -Seconds 8
        $youtubeWindow = Get-Process msedge -ErrorAction SilentlyContinue |
            Where-Object { $_.MainWindowHandle -ne 0 -and $_.MainWindowTitle -like '*YouTube*' } |
            Select-Object -First 1
        if ($youtubeWindow) {
            $shell = New-Object -ComObject WScript.Shell
            [void]$shell.AppActivate($youtubeWindow.Id)
            Start-Sleep -Milliseconds 500
            $shell.SendKeys('f')
        }

        $target = $null
        for ($attempt = 0; $attempt -lt 40 -and -not $target; $attempt++) {
            try {
                $targets = Invoke-RestMethod -Uri "http://127.0.0.1:$debugPort/json" -TimeoutSec 1 -ErrorAction Stop
                $target = $targets | Where-Object { $_.type -eq 'page' -and $_.url -like '*youtube.com/watch*' } | Select-Object -First 1
            } catch { }
            if (-not $target) { Start-Sleep -Milliseconds 500 }
        }

        $videoEnded = $false
        if ($target) {
            $socket = New-Object System.Net.WebSockets.ClientWebSocket
            try {
                $socket.ConnectAsync([Uri]$target.webSocketDebuggerUrl, [Threading.CancellationToken]::None).GetAwaiter().GetResult()
                $messageId = 0
                $videoStarted = $false
                while (-not $videoEnded -and -not $edgeSession.HasExited) {
                    $messageId++
                    $payload = @{
                        id = $messageId
                        method = 'Runtime.evaluate'
                        params = @{
                            expression = "(() => { const v = document.querySelector('video'); return v ? { ended: v.ended, currentTime: v.currentTime } : null; })()"
                            returnByValue = $true
                        }
                    } | ConvertTo-Json -Depth 5 -Compress
                    $bytes = [Text.Encoding]::UTF8.GetBytes($payload)
                    $segment = [ArraySegment[byte]]::new($bytes)
                    $socket.SendAsync($segment, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, [Threading.CancellationToken]::None).GetAwaiter().GetResult()

                    $response = $null
                    do {
                        $buffer = New-Object byte[] 8192
                        $responseText = [Text.StringBuilder]::new()
                        do {
                            $receiveSegment = [ArraySegment[byte]]::new($buffer)
                            $received = $socket.ReceiveAsync($receiveSegment, [Threading.CancellationToken]::None).GetAwaiter().GetResult()
                            if ($received.MessageType -eq [System.Net.WebSockets.WebSocketMessageType]::Close) { break }
                            [void]$responseText.Append([Text.Encoding]::UTF8.GetString($buffer, 0, $received.Count))
                        } while (-not $received.EndOfMessage)
                        if ($received.MessageType -eq [System.Net.WebSockets.WebSocketMessageType]::Close) { break }
                        $response = $responseText.ToString() | ConvertFrom-Json
                    } while ($response.id -ne $messageId)

                    if ($response.id -eq $messageId -and $response.result.result.value) {
                        $videoState = $response.result.result.value
                        if ($videoState.currentTime -gt 0.2) { $videoStarted = $true }
                        if ($videoStarted -and $videoState.ended) { $videoEnded = $true }
                    }
                    if (-not $videoEnded) { Start-Sleep -Seconds 1 }
                }
            } finally {
                if ($socket.State -eq [System.Net.WebSockets.WebSocketState]::Open) {
                    $socket.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, 'Video finished', [Threading.CancellationToken]::None).GetAwaiter().GetResult()
                }
                $socket.Dispose()
            }
        }

        if ($videoEnded -and -not $edgeSession.HasExited) {
            $edgeSession.CloseMainWindow() | Out-Null
            if (-not $edgeSession.WaitForExit(5000)) { $edgeSession.Kill() }

            $scareSource = @"
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Windows.Forms;

public class FunJumpScareForm : Form
{
    private readonly Timer timer = new Timer();
    private int ticks = 0;

    public void ShowScare() { ShowDialog(); }

    public FunJumpScareForm()
    {
        FormBorderStyle = FormBorderStyle.None;
        WindowState = FormWindowState.Maximized;
        BackColor = Color.Black;
        TopMost = true;
        DoubleBuffered = true;
        KeyPreview = true;
        KeyDown += (s, e) => { if (e.KeyCode == Keys.Escape) Close(); };
        timer.Interval = 30;
        timer.Tick += (s, e) => {
            ticks++;
            BackColor = ticks % 4 == 0 ? Color.FromArgb(45, 0, 0) : Color.Black;
            if (ticks >= 60) { Close(); return; }
            Invalidate();
        };
        Shown += (s, e) => timer.Start();
        FormClosed += (s, e) => timer.Dispose();
    }

    protected override void OnPaint(PaintEventArgs e)
    {
        base.OnPaint(e);
        e.Graphics.SmoothingMode = SmoothingMode.AntiAlias;
        int size = Math.Min(ClientSize.Width, ClientSize.Height) * 3 / 4;
        int x = (ClientSize.Width - size) / 2;
        int y = (ClientSize.Height - size) / 2;
        using (Brush face = new SolidBrush(Color.FromArgb(220, 215, 205)))
            e.Graphics.FillEllipse(face, x, y, size, size);
        using (Brush shadow = new SolidBrush(Color.FromArgb(20, 0, 0))) {
            e.Graphics.FillEllipse(shadow, x + size*18/100, y + size*32/100, size*25/100, size*18/100);
            e.Graphics.FillEllipse(shadow, x + size*57/100, y + size*32/100, size*25/100, size*18/100);
            e.Graphics.FillEllipse(shadow, x + size*34/100, y + size*68/100, size*33/100, size*18/100);
        }
        using (Brush red = new SolidBrush(Color.Red)) {
            e.Graphics.FillEllipse(red, x + size*25/100, y + size*37/100, size*10/100, size*9/100);
            e.Graphics.FillEllipse(red, x + size*65/100, y + size*37/100, size*10/100, size*9/100);
        }
        using (Brush teeth = new SolidBrush(Color.White)) {
            for (int i = 0; i < 5; i++)
                e.Graphics.FillRectangle(teeth, x + size*(39 + i*5)/100, y + size*70/100, size*3/100, size*8/100);
        }
    }
}
"@
            Add-Type -TypeDefinition $scareSource -ReferencedAssemblies @('System.Windows.Forms', 'System.Drawing')
            $scarePlayer = $null
            if ($playSounds) {
                Add-Type -AssemblyName PresentationCore
                $boomPath = Join-Path $PSScriptRoot 'boom.mp3'
                if (Test-Path -LiteralPath $boomPath) {
                    $scarePlayer = New-Object System.Windows.Media.MediaPlayer
                    $scarePlayer.Volume = 0.8
                    $scarePlayer.Open([Uri]$boomPath)
                    $scarePlayer.Play()
                }
            }
            $scareForm = New-Object FunJumpScareForm
            $scareForm.ShowScare()
            if ($scarePlayer) { $scarePlayer.Stop(); $scarePlayer.Close() }
        }
    } else {
        Start-Process 'https://www.youtube.com/watch?v=mXTYvRf3qew&autoplay=1'
    }
}

