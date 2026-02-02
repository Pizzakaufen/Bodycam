const hud = {
    hud: document.getElementById('hud'),
    batt: document.getElementById('batt-symbol'),
    red: document.getElementById('red-light'),
    green: document.getElementById('green-light'),
    ready: document.getElementById('ready-symbol'),
    rec: document.getElementById('rec-symbol'),
    saving: document.getElementById('saving-symbol'),
    starting: document.getElementById('starting-symbol')
};

window.addEventListener('message', ({ data }) => {
    switch (data.action) {
        case 'showHUD':
            if (data.state) {
                hud.hud.classList.remove('hidden');
                hud.batt.classList.remove('hidden');

                toggleElement(hud.green, true, true);
                hud.ready.classList.remove('hidden');
            } else {
                Object.values(hud).forEach(el => {
                    if (el && el.classList) {
                        el.classList.add('hidden');
                        el.classList.remove('blinking');
                    }
                });
            }
            break;

        case 'ready':
            toggleElement(hud.green, data.ready, true);
            toggleElement(hud.ready, data.ready);
            break;

        case 'recording':
            toggleElement(hud.red, data.recording, true);
            toggleElement(hud.rec, data.recording);
            break;

        case 'saving':
            toggleElement(hud.green, data.saving, true);
            toggleElement(hud.saving, data.saving);
            break;

        case 'starting':
            toggleElement(hud.red, data.starting, true);
            toggleElement(hud.starting, data.starting);
            break;
    }
});

function toggleElement(el, state, blink = false) {
    if (!el) return;
    el.classList.toggle('hidden', !state);

    if (blink && state) {
        el.classList.add('blinking');
    } else {
        el.classList.remove('blinking');
    }
}
