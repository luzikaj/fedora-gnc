# Speech Note: dictation and reading aloud

Speech Note (from Flathub) turns speech into text and text into speech,
**offline**, on your own computer. In Fedora GNC it types dictated text
straight into whichever window has focus: an editor, the browser, a chat or
the terminal.

## Keys

| Mod + | Action | Keycap |
|---|---|---|
| `c` | **start dictating** into the focused window | [L] |
| `i` | **stop dictating** (the text is typed in) | [B] |
| `a` | **read the clipboard aloud** | [F] |
| `x` | **stop reading** / cancel | [C] |

To read something aloud: select it, copy it (tap Right Ctrl, then `c`), then
press Mod + `a`.

With the listening mode set to **One sentence**, dictation stops by itself
after a pause, so Mod + `i` is rarely needed.

## First time

1. Open **Speech Note** from the launcher (Mod + `'`), or use the Welcome
   window's "Dictation" step.
2. In its languages and models settings, choose **Polish** and download a
   **speech-to-text** model (Whisper works well) and a **text-to-speech** voice.
3. Set the listening mode to **One sentence**.

Models are downloaded once and kept on disk; nothing is sent to the internet
while you dictate.

## How it works

- Speech Note waits in the tray from login, so a dictation starts instantly.
- Its window floats and **never takes the focus**: the text goes into the
  window you were in.
- It types through **ydotoold**, a small system service that provides a
  virtual keyboard (`onehand-ydotoold.service`). keyd leaves that virtual
  keyboard alone, so dictated Polish letters come through unchanged.

## If it doesn't type

- `systemctl status onehand-ydotoold`: the virtual keyboard should be running.
- Check that a model is downloaded and Polish is selected in Speech Note.
- The shortcuts run `flatpak run net.mkiol.SpeechNote --action …`; try one in
  a terminal to see any error message.

## Changing the keys

They're in `~/.config/niri/config.kdl`, in the section marked
"voice: Speech Note". Other available actions include `start-listening`
(text goes into Speech Note's own window) and `start-listening-clipboard`
(text goes to the clipboard).
