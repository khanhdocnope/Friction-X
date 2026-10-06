#include <windows.h>
#include <magnification.h>
#include <psapi.h>
#include <iostream>
#include <string>
#include <vector>

#pragma comment(lib, "Magnification.lib")

// Win32 Hook handles
static HWINEVENTHOOK g_foregroundHook = NULL;
static HHOOK g_mouseHook = NULL;
static bool g_isGrayscaleEnabled = false;
static bool g_isScrollLagEnabled = false;

// Con trỏ hàm callback gửi ngược về Dart/Flutter
typedef void (*AppLaunchCallback)(const char* processName);
static AppLaunchCallback g_dartCallback = NULL;

// 1. Chuyển đổi màn hình Desktop sang Grayscale bằng Magnification API
bool SetDesktopGrayscale(bool enable) {
    if (enable) {
        if (!MagInitialize()) return false;

        // Ma trận chuyển đổi ảnh màu sang Grayscale (Luminance matrix)
        MAGCOLOREFFECT magEffect = {{
            { 0.3f,  0.3f,  0.3f,  0.0f,  0.0f },
            { 0.59f, 0.59f, 0.59f, 0.0f, 0.0f },
            { 0.11f, 0.11f, 0.11f, 0.0f, 0.0f },
            { 0.0f,  0.0f,  0.0f,  1.0f,  0.0f },
            { 0.0f,  0.0f,  0.0f,  0.0f,  1.0f }
        }};

        g_isGrayscaleEnabled = MagSetFullscreenColorEffect(&magEffect);
        return g_isGrayscaleEnabled;
    } else {
        // Reset về ma trận đơn vị mặc định (Màu sắc bình thường)
        MAGCOLOREFFECT identity = {{
            { 1.0f,  0.0f,  0.0f,  0.0f,  0.0f },
            { 0.0f,  1.0f,  0.0f,  0.0f,  0.0f },
            { 0.0f,  0.0f,  1.0f,  0.0f,  0.0f },
            { 0.0f,  0.0f,  0.0f,  1.0f,  0.0f },
            { 0.0f,  0.0f,  0.0f,  0.0f,  1.0f }
        }};
        MagSetFullscreenColorEffect(&identity);
        MagUninitialize();
        g_isGrayscaleEnabled = false;
        return true;
    }
}

// 2. Low-Level Mouse Hook tạo Scroll Lag cho con lăn chuột
LRESULT CALLBACK LowLevelMouseProc(int nCode, WPARAM wParam, LPARAM lParam) {
    if (nCode >= 0 && wParam == WM_MOUSEWHEEL) {
        if (g_isScrollLagEnabled) {
            static DWORD lastTick = 0;
            DWORD now = GetTickCount();

            // Nếu cuộn quá nhanh (< 200ms), cố tình nuốt (drop) gói tin cuộn để làm giật chuột
            if (now - lastTick < 200) {
                return 1; // Nuốt sự kiện cuộn -> Gây ức chế, tê liệt cuộn mượt
            }
            lastTick = now;
        }
    }
    return CallNextHookEx(g_mouseHook, nCode, wParam, lParam);
}

// 3. Callback bắt sự kiện chuyển cửa sổ foreground trên Windows
void CALLBACK WinEventProc(
    HWINEVENTHOOK hWinEventHook,
    DWORD event,
    HWND hwnd,
    LONG idObject,
    LONG idChild,
    DWORD idEventThread,
    DWORD dwmsEventTime
) {
    if (event == EVENT_SYSTEM_FOREGROUND && hwnd != NULL) {
        DWORD processId = 0;
        GetWindowThreadProcessId(hwnd, &processId);

        if (processId != 0) {
            HANDLE hProcess = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, processId);
            if (hProcess != NULL) {
                char processName[MAX_PATH];
                DWORD size = MAX_PATH;
                if (QueryFullProcessImageNameA(hProcess, 0, processName, &size)) {
                    // Trích xuất tên file .exe từ đường dẫn
                    std::string fullPath(processName);
                    size_t pos = fullPath.find_last_of("\\/");
                    std::string exeName = (pos != std::string::npos) ? fullPath.substr(pos + 1) : fullPath;

                    if (g_dartCallback != NULL) {
                        g_dartCallback(exeName.c_str());
                    }
                }
                CloseHandle(hProcess);
            }
        }
    }
}

// C API xuất ra cho Flutter qua Dart FFI
extern "C" {
    __declspec(dllexport) void InitDesktopInterceptor(AppLaunchCallback callback) {
        g_dartCallback = callback;
        if (g_foregroundHook == NULL) {
            g_foregroundHook = SetWinEventHook(
                EVENT_SYSTEM_FOREGROUND, EVENT_SYSTEM_FOREGROUND,
                NULL, WinEventProc, 0, 0,
                WINEVENT_OUTOFCONTEXT | WINEVENT_SKIPOWNPROCESS
            );
        }
        if (g_mouseHook == NULL) {
            g_mouseHook = SetWindowsHookEx(WH_MOUSE_LL, LowLevelMouseProc, GetModuleHandle(NULL), 0);
        }
    }

    __declspec(dllexport) void SetGrayscaleMode(bool enable) {
        SetDesktopGrayscale(enable);
    }

    __declspec(dllexport) void SetScrollLagMode(bool enable) {
        g_isScrollLagEnabled = enable;
    }

    __declspec(dllexport) void MinimizeWindow(HWND hwnd) {
        ShowWindow(hwnd, SW_MINIMIZE);
    }

    __declspec(dllexport) void CleanupDesktopInterceptor() {
        if (g_foregroundHook != NULL) {
            UnhookWinEvent(g_foregroundHook);
            g_foregroundHook = NULL;
        }
        if (g_mouseHook != NULL) {
            UnhookWindowsHookEx(g_mouseHook);
            g_mouseHook = NULL;
        }
        SetDesktopGrayscale(false);
    }
}
