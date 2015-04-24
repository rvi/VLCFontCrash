The aim of this repo is just to illustrate a crash I've got with VLC, for the bug report.


Backtrace of the app :
```sh
(lldb) bt
* thread #6: tid = 0x11f383, 0x0000000112e3160d CoreFoundation`CFURLCopyFileSystemPath + 77, stop reason = EXC_BAD_ACCESS (code=1, address=0x0)
    frame #0: 0x0000000112e3160d CoreFoundation`CFURLCopyFileSystemPath + 77
  * frame #1: 0x00000001100c428f VLCFontCrash`Create(p_this=<unavailable>) + 815 at libass.c:232
    frame #2: 0x00000001100238e4 VLCFontCrash`vlc_module_load [inlined] module_load(obj=0x00007f86640284b8, init=<unavailable>) + 76 at modules.c:185
    frame #3: 0x0000000110023898 VLCFontCrash`vlc_module_load(obj=0x00007f86640284b8, capability=0x00000001101eeda9, name=<unavailable>, strict=false, probe=0x0000000110023bd0) + 1240 at modules.c:277
    frame #4: 0x000000010ffe9fb5 VLCFontCrash`decoder_New [inlined] CreateDecoder(p_parent=0x00007f8662d068c8, p_sout=0x0000000000000000) + 516 at decoder.c:786
    frame #5: 0x000000010ffe9db1 VLCFontCrash`decoder_New(p_parent=0x00007f8662d068c8, p_input=<unavailable>, fmt=0x00007f8662e2b1f8, p_clock=<unavailable>, p_resource=<unavailable>, p_sout=0x0000000000000000) + 65 at decoder.c:256
    frame #6: 0x000000010fff27c6 VLCFontCrash`EsCreateDecoder(out=0x00007f8662e325c0, p_es=0x00007f8662e2b1e0) + 54 at es_out.c:1557
    frame #7: 0x000000010fff1b4a VLCFontCrash`EsSelect(out=0x00007f8662e325c0, es=0x00007f8662e2b1e0) + 506 at es_out.c:1642
    frame #8: 0x000000010fff2599 VLCFontCrash`EsOutSelect(out=0x00007f8662e325c0, es=0x00007f8662e2b1e0, b_force=<unavailable>) + 1833 at es_out.c:1861
    frame #9: 0x000000010ffef879 VLCFontCrash`EsOutControlLocked(out=0x00007f8662e325c0, i_query=<unavailable>, args=<unavailable>) + 2473 at es_out.c:2180
    frame #10: 0x000000010ffeeb0e VLCFontCrash`EsOutControl(out=0x00007f8662e325c0, i_query=<unavailable>, args=<unavailable>) + 46 at es_out.c:2705
    frame #11: 0x000000010fff5660 VLCFontCrash`es_out_Control [inlined] es_out_vaControl(out=<unavailable>, i_query=<unavailable>, args=0x0000003000000018) + 3 at vlc_es_out.h:126
    frame #12: 0x000000010fff565d VLCFontCrash`es_out_Control(out=<unavailable>, i_query=<unavailable>) + 157 at vlc_es_out.h:135
    frame #13: 0x000000010fff4e2c VLCFontCrash`Control [inlined] ControlLocked(p_out=<unavailable>, i_query=<unavailable>) + 2908 at es_out_timeshift.c:618
    frame #14: 0x000000010fff42d0 VLCFontCrash`Control(p_out=<unavailable>, i_query=<unavailable>, args=<unavailable>) + 224 at es_out_timeshift.c:716
    frame #15: 0x000000010fffa520 VLCFontCrash`es_out_Control [inlined] es_out_vaControl(out=<unavailable>, i_query=<unavailable>, args=0x0000003000000018) + 3 at vlc_es_out.h:126
    frame #16: 0x000000010fffa51d VLCFontCrash`es_out_Control(out=<unavailable>, i_query=<unavailable>) + 157 at vlc_es_out.h:135
    frame #17: 0x000000010fff872c VLCFontCrash`Init [inlined] es_out_SetMode(p_out=<unavailable>) + 7 at es_out.h:89
    frame #18: 0x000000010fff8725 VLCFontCrash`Init [inlined] InitPrograms(p_input=0x00007f8662d068c8) + 350 at input.c:1155
    frame #19: 0x000000010fff85c7 VLCFontCrash`Init(p_input=0x00007f8662d068c8) + 4423 at input.c:1233
    frame #20: 0x000000010fff9ed6 VLCFontCrash`Run(obj=0x00007f8662d068c8) + 22 at input.c:515
    frame #21: 0x0000000114e94268 libsystem_pthread.dylib`_pthread_body + 131
    frame #22: 0x0000000114e941e5 libsystem_pthread.dylib`_pthread_start + 176
    frame #23: 0x0000000114e9241d libsystem_pthread.dylib`thread_start + 13
```


### Primary Investigation


The app crash in `libass.c` at line 232 :

```c
CFURLRef fileURL;
fileURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("OpenSans-Regular.ttf"),
                                      NULL,
                                      NULL);
CFStringRef urlString = CFURLCopyFileSystemPath(fileURL, kCFURLPOSIXPathStyle);
CFRelease(fileURL);
```

It appears that `fileURL` is `NULL`, which leads `CFURLCopyFileSystemPath(fileURL, kCFURLPOSIXPathStyle)` to crash.

A possible fix should be : 


```c
CFURLRef fileURL;
fileURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("OpenSans-Regular.ttf"),
                                      NULL,
                                      NULL);
if (fileURL != NULL)
{
	CFStringRef urlString = CFURLCopyFileSystemPath(fileURL, kCFURLPOSIXPathStyle);
	CFRelease(fileURL);
}
```

### So why not submit a patch to VLC ?

I tried to compile VLC code on my mac (OSX 10.10.3, Xcode 6.3.1) and it didn't worked, I don't have a lot of time right now  to understand why  clang doesn't find the file to compile (But maybe when I'll have more time I'll try make to work).

If I can't test it myself, I won't submit a patch.


### Playing the same file on a mac with VLC 2.2.1

I've got this popup for few minutes, and after the video is playing correctly.

[VLC_Popup](https://github.com/rvi/VLCFontCrash/blob/master/vlcFontBuilding.png?raw=true)


