# Claude Code Hook Assets

This directory contains audio files and other assets used by Claude Code hooks.

## Audio Files

The hooks use audio notifications to provide audible feedback for different events:

### Success/Completion Sounds
- **toasty.mp3** - Plays when operations complete successfully
  - Used for: Session completion, successful formatting, tests passing
  - Context: Positive feedback for successful operations

### Warning/Error Sounds
- **gutter-trash.mp3** - Plays for warnings, errors, and blocked actions
  - Used for: Security violations, blocked commands, errors, permission requests
  - Context: Attention-grabbing sound for issues requiring user attention

## Audio Players

The hooks will automatically detect and use available audio players:

1. **mpg123** (recommended for Linux) - Lightweight MP3 player
   - Install: `apt-get install mpg123` (Ubuntu/Debian)
   - Install: `yum install mpg123` (CentOS/RHEL)

2. **mpv** - Modern media player
   - Install: `apt-get install mpv` (Ubuntu/Debian)

3. **paplay** - PulseAudio player for WAV files
   - Usually pre-installed on Linux systems

4. **ffplay** - Part of ffmpeg suite
   - Install: `apt-get install ffmpeg`

## Configuration

Audio notifications can be controlled via the hooks configuration:

```json
{
  "notifications": {
    "sound_enabled": true
  }
}
```

Set `sound_enabled` to `false` to disable all audio notifications.

## Adding Custom Audio Files

To add your own notification sounds:

1. Place MP3 files in this directory
2. Update hook scripts to reference your custom files
3. Ensure files are reasonably short (< 5 seconds recommended)
4. Keep file sizes small for quick playback

## Troubleshooting

### No Sound Playing
- Check if audio players are installed
- Verify audio files exist and are readable
- Check system volume and audio output
- Review hook logs in `~/.claude/logs/hooks.log`

### Permission Issues
- Ensure hook scripts are executable: `chmod +x .claude/hooks/**/*.sh`
- Check file ownership and permissions on audio files

### Audio Not Found
- Verify files are in the correct location: `.claude/hooks/assets/`
- Check file names match exactly (case-sensitive)
- Ensure paths are correct in hook scripts
