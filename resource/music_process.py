import argparse
import math
parser = argparse.ArgumentParser(description='midi converter')
parser.add_argument('midi_path', type=str, help='path to the midi that you want to convert')
parser.add_argument('track', type=int, help='track number')
args = parser.parse_args()


import mido
mid = mido.MidiFile(args.midi_path)
timing = {0: []}
current_time = 0
max_notes_in_track = 0
track = args.track
for i, msg in enumerate(mid.tracks[track]):
    if isinstance(msg, mido.Message):
        if msg.type.startswith( 'note_'): 
            print(i, msg)
            prev_notes = list(timing.get(current_time, []))
            current_time += msg.time
            print(current_time)
            if msg.type == 'note_on' and msg.velocity > 0:
                prev_notes.append(msg.note)
            else:
                prev_notes.remove(msg.note)
            timing[current_time] = prev_notes
            max_notes_in_track = max(len(prev_notes), max_notes_in_track)
ticks_per_beat = mid.ticks_per_beat
tempo = 375000

for i in timing:
    timing[i].extend([0] * (max_notes_in_track - len(timing[i])))

import pickle
timing_index = list(timing)
midi_freq = pickle.load(open('midi_note.dat', 'rb'))
files = list(map(lambda ch : open("track_{}_ch_{}.hex".format(track, ch), "w"), range(max_notes_in_track)))
for i in range(len(timing_index) - 1):
    delta_ticks = timing_index[i + 1] - timing_index[i]
    idx = timing_index[i]
    duration = int(mido.tick2second(delta_ticks, ticks_per_beat, tempo) * 1000)
    data = list(map(lambda x : 0 if x == 0 else 100000000 // (midi_freq[x] * 64), timing[idx]))
    print(duration)
    print(data)
    list(map(lambda t : t[1].write("{0:04x}{1:04x}\n".format(int(data[t[0]]), duration)), enumerate(files)))
