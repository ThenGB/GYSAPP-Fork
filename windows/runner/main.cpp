#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM for WebView2 and other plugins.
  // Use CoInitializeEx with COINIT_APARTMENTTHREADED as required by WebView2.
  // We call CoUninitialize first to ensure we can set the threading model we need,
  // in case another library already initialized it differently.
  ::CoUninitialize(); 
  HRESULT hr = ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
  if (FAILED(hr)) {
    if (hr == RPC_E_CHANGED_MODE) {
      // If we still get this, it means we really can't change it on this thread.
    } else {
      return EXIT_FAILURE;
    }
  }

  // Also initialize OLE for drag-and-drop and other shell interactions.
  ::OleUninitialize(); // Clear existing OLE if any
  if (FAILED(::OleInitialize(nullptr))) {
    // If OleInitialize fails, we still have COM from CoInitializeEx.
  }

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"church", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::OleUninitialize();
  ::CoUninitialize();
  return EXIT_SUCCESS;
}
