import os
import sys
import shutil
import zipfile
import platform
import threading
import requests
import json
import customtkinter as ctk # type: ignore
from tkinter import filedialog, messagebox

ctk.set_appearance_mode("System")
ctk.set_default_color_theme("green")

def get_resource_path(relative_path):
    """Resolve a bundled resource path.
    - Frozen (PyInstaller): resources are extracted to sys._MEIPASS at runtime.
    - Script: resources sit next to the .py file.
    """
    if getattr(sys, 'frozen', False):
        base = sys._MEIPASS
    else:
        base = os.path.dirname(os.path.abspath(__file__))
    return os.path.join(base, relative_path)

class InstallerApp(ctk.CTk):
    def __init__(self):
        super().__init__()

        self.title("Etched Worship Installer Wizard")
        self.geometry("650x450")
        self.resizable(False, False)

        self.github_user = "kenkaroki"
        self.github_repo = "Etched-Worship"

        if platform.system() == "Windows":
            self.download_url = f"https://github.com/{self.github_user}/{self.github_repo}/releases/download/windows-1.0.0/windows-1.0.0.zip"
            self.platform_folder = "windows"
        elif platform.system() == "Darwin":
            self.download_url = f"https://github.com/{self.github_user}/{self.github_repo}/releases/download/macos-1.0.0/macos-1.0.0.zip"
            self.platform_folder = "macos"
        else:
            self.download_url = f"https://github.com/{self.github_user}/{self.github_repo}/releases/download/linux-1.0.0/linux-1.0.0.zip"
            self.platform_folder = "linux"

        self.backgrounds_url = f"https://github.com/{self.github_user}/{self.github_repo}/archive/refs/heads/backgrounds.zip"

        self.install_dir = ctk.StringVar(value=self.get_default_install_dir())
        self.create_shortcut_var = ctk.BooleanVar(value=True)

        self.pages = [WelcomePage, DestinationPage, OptionsPage, ProgressPage, SuccessPage]
        self.current_page_index = 0
        self.current_page = None
        self.show_page(0)

    def get_default_install_dir(self):
        home = os.path.expanduser("~")
        if platform.system() == "Windows":
            return os.path.join(os.environ.get("ProgramFiles", "C:\\Program Files"), "Etched Worship")
        elif platform.system() == "Darwin":
            return os.path.join("/Applications", "Etched Worship")
        return os.path.join(home, ".Etched Worship")

    def show_page(self, index):
        if self.current_page: self.current_page.destroy()
        self.current_page_index = index
        self.current_page = self.pages[index](self)
        self.current_page.pack(fill="both", expand=True)

    def next_page(self):
        if self.current_page_index < len(self.pages) - 1: self.show_page(self.current_page_index + 1)

    def prev_page(self):
        if self.current_page_index > 0: self.show_page(self.current_page_index - 1)


# --- WIZARD PAGES ---

class WelcomePage(ctk.CTkFrame):
    def __init__(self, parent):
        super().__init__(parent)
        label = ctk.CTkLabel(self, text="Welcome to the App Installer", font=("Arial", 24, "bold"))
        label.pack(pady=(60, 20))
        desc = ctk.CTkLabel(self, text="This wizard will guide you through installing the application setup.\nClick Next to continue.", font=("Arial", 14), justify="center")
        desc.pack(pady=20)
        btn_next = ctk.CTkButton(self, text="Next >", command=parent.next_page)
        btn_next.pack(side="bottom", anchor="se", padx=30, pady=30)

class DestinationPage(ctk.CTkFrame):
    def __init__(self, parent):
        super().__init__(parent)
        self.parent = parent
        label = ctk.CTkLabel(self, text="Select Installation Folder", font=("Arial", 20, "bold"))
        label.pack(pady=(40, 20), anchor="w", padx=40)

        frame_search = ctk.CTkFrame(self, fg_color="transparent")
        frame_search.pack(fill="x", padx=40, pady=10)
        self.entry = ctk.CTkEntry(frame_search, textvariable=parent.install_dir, width=400)
        self.entry.pack(side="left", padx=(0, 10), fill="x", expand=True)
        btn_browse = ctk.CTkButton(frame_search, text="Browse...", width=100, command=self.browse_folder)
        btn_browse.pack(side="right")

        frame_nav = ctk.CTkFrame(self, fg_color="transparent")
        frame_nav.pack(side="bottom", fill="x", padx=30, pady=30)
        btn_back = ctk.CTkButton(frame_nav, text="< Back", command=parent.prev_page, width=100)
        btn_back.pack(side="left")
        btn_next = ctk.CTkButton(frame_nav, text="Next >", command=parent.next_page, width=100)
        btn_next.pack(side="right")

    def browse_folder(self):
        selected = filedialog.askdirectory(initialdir=self.parent.install_dir.get())
        if selected: self.parent.install_dir.set(os.path.normpath(selected))

class OptionsPage(ctk.CTkFrame):
    def __init__(self, parent):
        super().__init__(parent)
        label = ctk.CTkLabel(self, text="Select Additional Tasks", font=("Arial", 20, "bold"))
        label.pack(pady=(40, 20), anchor="w", padx=40)
        checkbox = ctk.CTkCheckBox(self, text="Create a Desktop Shortcut", variable=parent.create_shortcut_var)
        checkbox.pack(anchor="w", padx=50, pady=20)

        frame_nav = ctk.CTkFrame(self, fg_color="transparent")
        frame_nav.pack(side="bottom", fill="x", padx=30, pady=30)
        btn_back = ctk.CTkButton(frame_nav, text="< Back", command=parent.prev_page, width=100)
        btn_back.pack(side="left")
        btn_next = ctk.CTkButton(frame_nav, text="Install", fg_color="green", hover_color="dark green", command=parent.next_page, width=100)
        btn_next.pack(side="right")

class ProgressPage(ctk.CTkFrame):
    def __init__(self, parent):
        super().__init__(parent)
        self.parent = parent
        self.label = ctk.CTkLabel(self, text="Installing...", font=("Arial", 20, "bold"))
        self.label.pack(pady=(60, 10), anchor="w", padx=40)
        self.status_label = ctk.CTkLabel(self, text="Initializing download environment...", font=("Arial", 12))
        self.status_label.pack(anchor="w", padx=40, pady=(0, 20))
        self.progress_bar = ctk.CTkProgressBar(self, width=550)
        self.progress_bar.set(0)
        self.progress_bar.pack(padx=40, pady=10)

        threading.Thread(target=self.start_installation, daemon=True).start()

    def update_status(self, text, percentage=None):
        self.status_label.configure(text=text)
        if percentage is not None: self.progress_bar.set(percentage / 100)
        self.update_idletasks()

    def download_file(self, url, dest_path, start_pct, end_pct, status_prefix):
        headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"}
        response = requests.get(url, headers=headers, stream=True, allow_redirects=True)
        response.raise_for_status()
        total_length = response.headers.get('content-length')

        with open(dest_path, "wb") as f:
            if total_length is None:
                f.write(response.content)
            else:
                downloaded = 0
                total_length = int(total_length)
                for chunk in response.iter_content(chunk_size=8192):
                    if chunk:
                        downloaded += len(chunk)
                        f.write(chunk)
                        pct_range = end_pct - start_pct
                        percentage = start_pct + int(pct_range * (downloaded / total_length))
                        self.update_status(f"{status_prefix}: {downloaded // 1024} KB received", percentage)

    def create_launcher_files(self, target_dir):
        """Create platform-specific launcher scripts that open both canvas and control_panel."""
        os_type = platform.system()

        if os_type == "Windows":
            # The actual launcher
            bat_path = os.path.join(target_dir, "Etched Worship.bat")
            with open(bat_path, "w", newline="\r\n") as f:
                f.write("@echo off\r\n")
                f.write('start "" "%~dp0canvas\\canvas.exe"\r\n')
                f.write('start "" "%~dp0control_panel\\control_panel.exe"\r\n')

            # Silent VBScript wrapper — shortcut points here so no CMD window flashes
            vbs_path = os.path.join(target_dir, "Etched Worship.vbs")
            with open(vbs_path, "w") as f:
                f.write("Dim objShell, strDir\n")
                f.write('Set objShell = CreateObject("WScript.Shell")\n')
                f.write('strDir = CreateObject("Scripting.FileSystemObject")'
                        '.GetParentFolderName(WScript.ScriptFullName)\n')
                f.write('objShell.Run Chr(34) & strDir & "\\Etched Worship.bat"'
                        ' & Chr(34), 0, False\n')
                f.write("Set objShell = Nothing\n")

            return vbs_path  # shortcut targets the silent wrapper

        elif os_type == "Darwin":
            launcher_path = os.path.join(target_dir, "Etched Worship.command")
            with open(launcher_path, "w") as f:
                f.write("#!/bin/bash\n")
                f.write('DIR="$(cd "$(dirname "$0")" && pwd)"\n')
                f.write('open "$DIR/canvas/canvas.app"\n')
                f.write('open "$DIR/control_panel/control_panel.app"\n')
            os.chmod(launcher_path, 0o755)
            return launcher_path

        else:  # Linux
            launcher_path = os.path.join(target_dir, "Etched Worship.sh")
            with open(launcher_path, "w") as f:
                f.write("#!/bin/bash\n")
                f.write('DIR="$(cd "$(dirname "$0")" && pwd)"\n')
                f.write('"$DIR/canvas/canvas" &\n')
                f.write('"$DIR/control_panel/control_pannel" &\n')
            os.chmod(launcher_path, 0o755)
            return launcher_path

    def start_installation(self):
        try:
            base_dir = self.parent.install_dir.get()
            target_dir = os.path.join(base_dir, "Etched Worship")
            user_home = os.path.expanduser("~")

            zip_tmp_path = os.path.join(user_home, "installer_tmp.zip")
            bg_tmp_path = os.path.join(user_home, "backgrounds_tmp.zip")

            # Step 1: Download Core Apps Packaging
            self.download_file(self.parent.download_url, zip_tmp_path, 5, 45, "Downloading core application files")

            # Step 2: Download Background Assets Branch
            self.download_file(self.parent.backgrounds_url, bg_tmp_path, 45, 65, "Downloading media background assets")

            # Step 3: Extract Application Binaries
            self.update_status("Extracting core binaries...", 70)
            os.makedirs(target_dir, exist_ok=True)

            target_os = self.parent.platform_folder
            with zipfile.ZipFile(zip_tmp_path, 'r') as main_zip:
                for member in main_zip.namelist():
                    normalized_member = member.replace('\\', '/')
                    path_parts = normalized_member.split('/')

                    if target_os in path_parts:
                        filename = path_parts[-1]
                        if filename in ["canvas.zip", "control_panel.zip"]:
                            nested_zip_tmp = os.path.join(target_dir, f"tmp_{filename}")
                            with main_zip.open(member) as source, open(nested_zip_tmp, "wb") as target:
                                shutil.copyfileobj(source, target)

                            if zipfile.is_zipfile(nested_zip_tmp):
                                app_name = filename[:-4]  # "canvas" or "control_panel"
                                app_dir = os.path.join(target_dir, app_name)
                                os.makedirs(app_dir, exist_ok=True)
                                with zipfile.ZipFile(nested_zip_tmp, 'r') as nested_ref:
                                    nested_ref.extractall(app_dir)
                            if os.path.exists(nested_zip_tmp):
                                os.remove(nested_zip_tmp)

            # Step 4: Extract and Handle Background Images
            self.update_status("Processing system graphics library...", 80)
            extracted_bg_root = os.path.join(target_dir, f"{self.parent.github_repo}-backgrounds")

            with zipfile.ZipFile(bg_tmp_path, 'r') as bg_zip:
                bg_zip.extractall(target_dir)

            final_bg_dir = os.path.join(target_dir, "backgrounds")
            if os.path.exists(final_bg_dir):
                shutil.rmtree(final_bg_dir)

            src_images_folder = os.path.join(extracted_bg_root, "images")
            if os.path.exists(src_images_folder):
                shutil.move(src_images_folder, final_bg_dir)

            if os.path.exists(extracted_bg_root):
                shutil.rmtree(extracted_bg_root)

            # Step 5: Read Background Directory & Generate Config JSON
            self.update_status("Indexing image repository details...", 85)
            image_extensions = ('.png', '.jpg', '.jpeg', '.webp', '.bmp')
            found_image_paths = []

            if os.path.exists(final_bg_dir):
                for file in os.listdir(final_bg_dir):
                    if file.lower().endswith(image_extensions):
                        full_img_path = os.path.normpath(os.path.join(final_bg_dir, file))
                        found_image_paths.append(full_img_path)

            packagefiles_dir = os.path.join(target_dir, "packagefiles")
            os.makedirs(packagefiles_dir, exist_ok=True)

            open(os.path.join(packagefiles_dir, "stack.ecw.stc"), "w").close()
            open(os.path.join(packagefiles_dir, "songs.ecw.json"), "w").close()

            bg_config = {
                "solid": ["Blue", "Red", "Green", "Black", "Purple", "Orange", "Pink", "Lime", "Brown", "Teal", "Indigo"],
                "image": found_image_paths
            }

            bg_file_path = os.path.join(packagefiles_dir, "slide_backgrounds.ecw.bgs.json")
            with open(bg_file_path, "w") as bg_file:
                json.dump(bg_config, bg_file, indent=2)

            # Cleanup Downloads
            for path in [zip_tmp_path, bg_tmp_path]:
                if os.path.exists(path): os.remove(path)

            # Step 6: Create Launcher Files
            self.update_status("Creating application launcher...", 92)
            launcher_path = self.create_launcher_files(target_dir)

            # Step 7: Copy bundled icon to install dir for a permanent shortcut reference,
            # then create the shortcut pointing at that stable copy.
            icon_path = None
            if self.parent.create_shortcut_var.get() or True:  # always copy icon regardless
                bundled_icon = get_resource_path(os.path.join("icons", "Etched Worship.ico"))
                installed_icon = os.path.join(target_dir, "Etched Worship.ico")
                if os.path.exists(bundled_icon):
                    shutil.copy2(bundled_icon, installed_icon)
                    icon_path = installed_icon

            # Step 8: Shortcut Setup
            if self.parent.create_shortcut_var.get():
                self.update_status("Creating desktop shortcuts...", 96)
                self.create_shortcut(launcher_path, "Etched Worship", icon_path)

            self.update_status("Installation complete!", 100)
            self.parent.after(500, self.parent.next_page)

        except Exception as e:
            messagebox.showerror("Installation Error", f"An error occurred during installation:\n{str(e)}")
            self.parent.show_page(1)

    def create_shortcut(self, target_exe, app_name, icon_path=None):
        os_type = platform.system()
        desktop = os.path.join(os.path.expanduser("~"), "Desktop")

        if os_type == "Windows":
            try:
                from win32com.client import Dispatch
                shortcut_path = os.path.join(desktop, f"{app_name}.lnk")
                shell = Dispatch('WScript.Shell')
                shortcut = shell.CreateShortCut(shortcut_path)
                shortcut.Targetpath = target_exe
                shortcut.WorkingDirectory = os.path.dirname(target_exe)
                if icon_path and os.path.exists(icon_path):
                    shortcut.IconLocation = f"{icon_path}, 0"
                shortcut.save()
            except: pass

        elif os_type == "Darwin":
            try:
                symlink_path = os.path.join(desktop, app_name)
                os.symlink(target_exe, symlink_path)
                if icon_path and os.path.exists(icon_path):
                    script = (
                        f'tell application "Finder" to set the icon of '
                        f'(POSIX file "{symlink_path}") to '
                        f'(POSIX file "{icon_path}") as alias'
                    )
                    os.system(f"osascript -e '{script}'")
            except: pass

        elif os_type == "Linux":
            try:
                desktop_file = os.path.join(desktop, f"{app_name}.desktop")
                with open(desktop_file, "w") as f:
                    f.write(f"[Desktop Entry]\nType=Application\nName={app_name}\n")
                    f.write(f"Exec={target_exe}\nTerminal=false\n")
                    if icon_path and os.path.exists(icon_path):
                        f.write(f"Icon={icon_path}\n")
                os.chmod(desktop_file, 0o755)
            except: pass

class SuccessPage(ctk.CTkFrame):
    def __init__(self, parent):
        super().__init__(parent)
        label = ctk.CTkLabel(self, text="Installation Successful!", font=("Arial", 24, "bold"), text_color="green")
        label.pack(pady=(60, 20))
        desc = ctk.CTkLabel(self, text="The application was installed successfully on your computer.\nClick Finish to exit the wizard.", font=("Arial", 14))
        desc.pack(pady=20)
        btn_finish = ctk.CTkButton(self, text="Finish", command=parent.destroy)
        btn_finish.pack(side="bottom", anchor="se", padx=30, pady=30)

def is_admin():
    try:
        if platform.system() == "Windows":
            import ctypes
            return ctypes.windll.shell32.IsUserAnAdmin() != 0
        return os.getuid() == 0
    except: return False

if __name__ == "__main__":
    if not is_admin():
        if platform.system() == "Windows":
            import ctypes
            ctypes.windll.shell32.ShellExecuteW(None, "runas", sys.executable, " ".join(sys.argv), None, 1)
            sys.exit(0)
        elif platform.system() == "Darwin":
            os.system(f"osascript -e 'do shell script \"python3 {' '.join(sys.argv)}\" with administrator privileges'")
            sys.exit(0)
        else:
            os.system(f"pkexec python3 {' '.join(sys.argv)} || sudo python3 {' '.join(sys.argv)}")
            sys.exit(0)

    app = InstallerApp()
    app.mainloop()