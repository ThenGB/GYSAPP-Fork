import base64

# Read all JS files that need to be in the worker
with open('assets/web/js/libfluidsynth-2.4.6.js', 'r', encoding='utf-8') as f:
    fluidsynth_code = f.read()

with open('assets/web/js/js-synthesizer.min.js', 'r', encoding='utf-8') as f:
    jssynth_code = f.read()

with open('assets/web/js/midi-render-worker.min.js', 'r', encoding='utf-8') as f:
    worker_code = f.read()

with open('assets/web/js/midi-engine.js', 'r', encoding='utf-8') as f:
    midi_engine_code = f.read()

# Concatenate: first load FluidSynth + JS Synthesizer, then worker code
# Remove the importScripts call from worker since scripts are already loaded
worker_code = worker_code.replace(
    'importScripts("libfluidsynth-2.4.6.js","js-synthesizer.min.js");',
    ''
)

full_worker_code = fluidsynth_code + '\n' + jssynth_code + '\n' + worker_code

# Base64 encode the full worker code (safe for embedding in JS strings)
full_worker_b64 = base64.b64encode(full_worker_code.encode('utf-8')).decode('ascii')

# Read template
with open('assets/web/midi_engine_template.html', 'r', encoding='utf-8') as f:
    template = f.read()

# Replace placeholders
template = template.replace('WORKER_BASE64_PLACEHOLDER', full_worker_b64)
template = template.replace('MIDI_ENGINE_CODE_PLACEHOLDER', midi_engine_code)

# Write final file
with open('assets/web/midi_engine.html', 'w', encoding='utf-8') as f:
    f.write(template)

print('Generated assets/web/midi_engine.html')
print(f'FluidSynth code size: {len(fluidsynth_code)} bytes')
print(f'JS Synthesizer code size: {len(jssynth_code)} bytes')
print(f'Worker code size: {len(worker_code)} bytes')
print(f'MIDI engine code size: {len(midi_engine_code)} bytes')
print(f'Total worker blob size: {len(full_worker_code)} bytes')
print(f'Worker base64 size: {len(full_worker_b64)} bytes')
print(f'Final HTML size: {len(template)} bytes')
