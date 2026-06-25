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

# Set initial theme and style
ctk.set_appearance_mode("System")  # Options: "System", "Dark", "Light"
ctk.set_default_color_theme("green")

class InstallerApp(ctk.CTk):
    def __init__(self):
        super().__init__()
        
        self.title("Etched Worship Installer Wizard")
        self.geometry("650x450")
        self.resizable(False, False)

        # Detect platform specific download URLs and folder names
        if platform.system() == "Windows":
            self.download_url = "https://github.com/kenkaroki/Etched-Worship/releases/download/windows-1.0.0/windows-1.0.0.zip" 
            self.platform_folder = "windows"
        elif platform.system() == "Darwin": # macos
            self.download_url = "https://github.com/kenkaroki/Etched-Worship/releases/download/macos-1.0.0/macos-1.0.0.zip" 
            self.platform_folder = "macos"
        else: # linux
            self.download_url = "https://github.com/kenkaroki/Etched-Worship/releases/download/linux-1.0.0/linux-1.0.0.zip" 
            self.platform_folder = "linux"
        
        print(f"[DEBUG] System Detected: {platform.system()}")
        print(f"[DEBUG] Targeted Download URL: {self.download_url}")
        print(f"[DEBUG] Expected Platform Folder Token: {self.platform_folder}")
        
        # Configuration Variables
        self.target_folders = ["canvas.zip", "control_panel.zip"]
        
        # Installer State
        self.install_dir = ctk.StringVar(value=self.get_default_install_dir())
        self.create_shortcut_var = ctk.BooleanVar(value=True)
        
        # Wizard Page management
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
        if self.current_page:
            self.current_page.destroy()
            
        self.current_page_index = index
        self.current_page = self.pages[index](self)
        self.current_page.pack(fill="both", expand=True)

    def next_page(self):
        if self.current_page_index < len(self.pages) - 1:
            self.show_page(self.current_page_index + 1)

    def prev_page(self):
        if self.current_page_index > 0:
            self.show_page(self.current_page_index - 1)


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
        
        desc = ctk.CTkLabel(self, text="The software will be installed in the folder specified below.", font=("Arial", 12))
        desc.pack(anchor="w", padx=40, pady=(0, 10))
        
        # Selection row
        frame_search = ctk.CTkFrame(self, fg_color="transparent")
        frame_search.pack(fill="x", padx=40, pady=10)
        
        self.entry = ctk.CTkEntry(frame_search, textvariable=parent.install_dir, width=400)
        self.entry.pack(side="left", padx=(0, 10), fill="x", expand=True)
        
        btn_browse = ctk.CTkButton(frame_search, text="Browse...", width=100, command=self.browse_folder)
        btn_browse.pack(side="right")
        
        # Navigation bottom
        frame_nav = ctk.CTkFrame(self, fg_color="transparent")
        frame_nav.pack(side="bottom", fill="x", padx=30, pady=30)
        
        btn_back = ctk.CTkButton(frame_nav, text="< Back", command=parent.prev_page, width=100)
        btn_back.pack(side="left")
        
        btn_next = ctk.CTkButton(frame_nav, text="Next >", command=parent.next_page, width=100)
        btn_next.pack(side="right")

    def browse_folder(self):
        selected = filedialog.askdirectory(initialdir=self.parent.install_dir.get())
        if selected:
            self.parent.install_dir.set(os.path.normpath(selected))


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
        
        # Run background installation task thread to keep UI interactive
        threading.Thread(target=self.start_installation, daemon=True).start()

    def update_status(self, text, percentage=None):
        self.status_label.configure(text=text)
        if percentage is not None:
            self.progress_bar.set(percentage / 100)
        self.update_idletasks()

    def start_installation(self):
        try:
            base_dir = self.parent.install_dir.get()
            target_dir = os.path.join(base_dir, "Etched Worship")
            zip_tmp_path = os.path.join(os.path.expanduser("~"), "installer_tmp.zip")
            
            print(f"\n[DEBUG STEP 1] Appending 'Etched Worship' to path. Target destination: {target_dir}")
            print(f"[DEBUG STEP 1] Downloading ZIP payload temporary location: {zip_tmp_path}")
            
            # Step 1: Download
            self.update_status("Connecting to download server...", 5)
            headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"}
            
            print(f"[DEBUG STEP 1] Sending GET request to: {self.parent.download_url}")
            response = requests.get(self.parent.download_url, headers=headers, stream=True, allow_redirects=True)
            response.raise_for_status()
            
            total_length = response.headers.get('content-length')
            print(f"[DEBUG STEP 1] Response Status Code: {response.status_code}")
            print(f"[DEBUG STEP 1] Reported Content-Length Header: {total_length}")
            
            with open(zip_tmp_path, "wb") as f:
                if total_length is None:
                    print("[DEBUG STEP 1] Header absent. Writing content without block metric loops.")
                    f.write(response.content)
                else:
                    downloaded = 0
                    total_length = int(total_length)
                    for chunk in response.iter_content(chunk_size=8192):
                        if chunk:
                            downloaded += len(chunk)
                            f.write(chunk)
                            percentage = 10 + int(50 * (downloaded / total_length))
                            self.update_status(f"Downloading packages: {downloaded // 1024} KB received", percentage)
            
            print(f"[DEBUG STEP 1] Download finished. Saved file physical size: {os.path.getsize(zip_tmp_path)} bytes")

            # Step 2: Extraction
            self.update_status("Extracting platform packages...", 60)
            print(f"\n[DEBUG STEP 2] Ensuring target directory exists: {target_dir}")
            os.makedirs(target_dir, exist_ok=True)
            
            print(f"[DEBUG STEP 2] Validating if file is an accessible ZIP...")
            if not zipfile.is_zipfile(zip_tmp_path):
                print("[DEBUG STEP 2 ERROR] Verification failed. File is corrupt or text masquerading as binary zip.")
                raise zipfile.BadZipFile("The downloaded file is corrupted or not recognized as a valid ZIP archive.")
            print("[DEBUG STEP 2] File validation successful.")

            target_os = self.parent.platform_folder
            match_found_count = 0
            
            print(f"[DEBUG STEP 2] Reading main ZIP structure records...")
            with zipfile.ZipFile(zip_tmp_path, 'r') as main_zip:
                all_members = main_zip.namelist()
                print(f"[DEBUG STEP 2] Total elements indexed inside main ZIP archive: {len(all_members)}")
                
                for index, member in enumerate(all_members):
                    normalized_member = member.replace('\\', '/')
                    path_parts = normalized_member.split('/')
                    
                    # Print out every item path found inside your file so we can see it
                    print(f"  -> File #{index}: Raw Path inside ZIP = '{member}' | Broken Down Parts = {path_parts}")
                    
                    if target_os in path_parts:
                        filename = path_parts[-1]
                        print(f"     [MATCH OS] Path contains '{target_os}'. Checking tail filename: '{filename}'")
                        
                        if filename == "canvas.zip" or filename == "control_panel.zip":
                            match_found_count += 1
                            print(f"     [MATCH FILE FOUND!] Unpacking inner targeted zip asset: {filename}")
                            self.update_status(f"Unpacking nested package {filename}...", 75)
                            
                            nested_zip_tmp = os.path.join(target_dir, f"tmp_{filename}")
                            print(f"     [MATCH] Extracting target block member to temp file destination: {nested_zip_tmp}")
                            
                            with main_zip.open(member) as source, open(nested_zip_tmp, "wb") as target:
                                shutil.copyfileobj(source, target)
                            
                            print(f"     [MATCH] Temp nested file written size: {os.path.getsize(nested_zip_tmp)} bytes")
                            print(f"     [MATCH] Validating if temp nested package is a valid zip archive...")
                            if zipfile.is_zipfile(nested_zip_tmp):
                                print(f"     [MATCH] Valid nested ZIP. Extracting contents straight into: {target_dir}")
                                with zipfile.ZipFile(nested_zip_tmp, 'r') as nested_ref:
                                    nested_ref.extractall(target_dir)
                                print(f"     [MATCH] Extraction of {filename} complete.")
                            else:
                                print(f"     [MATCH ERROR] Nested file '{nested_zip_tmp}' failed ZIP validation criteria check.")
                            
                            if os.path.exists(nested_zip_tmp):
                                os.remove(nested_zip_tmp)
                                print(f"     [MATCH] Cleaned up inner temporary file path mapping successfully.")

            print(f"\n[DEBUG STEP 2 SUMMARY] Completed loop exploration. Matches caught & executed: {match_found_count}/2 targeted sub-packages.")
            
            if os.path.exists(zip_tmp_path):
                os.remove(zip_tmp_path)
                print("[DEBUG STEP 2] Main temporary download zip file cleaned from system storage safely.")

            # Step 3: Create 'packagefiles' and write data
            print(f"\n[DEBUG STEP 3] Creating 'packagefiles' data map...")
            self.update_status("Creating required package files...", 85)
            packagefiles_dir = os.path.join(target_dir, "packagefiles")
            os.makedirs(packagefiles_dir, exist_ok=True)
            print(f"[DEBUG STEP 3] Directories generated cleanly: {packagefiles_dir}")
            
            open(os.path.join(packagefiles_dir, "stack.ecw.stc"), "w").close()
            open(os.path.join(packagefiles_dir, "songs.ecw.json"), "w").close()
            print("[DEBUG STEP 3] Empty files generated successfully.")
            
            bg_config = {
                "solid": ["Blue", "Red", "Green", "Black", "Purple", "Orange", "Pink", "Lime", "Brown", "Teal", "Indigo"],
                "image": []
            }
            bg_file_path = os.path.join(packagefiles_dir, "slide_backgrounds.ecw.bgs.json")
            with open(bg_file_path, "w") as bg_file:
                json.dump(bg_config, bg_file, indent=2)
            print(f"[DEBUG STEP 3] Configuration file written cleanly to: {bg_file_path}")

            # Step 4: Handle Shortcut
            if self.parent.create_shortcut_var.get():
                print(f"\n[DEBUG STEP 4] Starting Desktop Shortcut routines...")
                self.update_status("Creating desktop shortcuts...", 95)
                exe_absolute_path = os.path.join(target_dir, "app_run") 
                if platform.system() == "Windows":
                    exe_absolute_path += ".exe"
                print(f"[DEBUG STEP 4] Target executable targeted link coordinate trace: {exe_absolute_path}")
                self.create_shortcut(exe_absolute_path, "Etched Worship")
                
            self.update_status("Installation complete!", 100)
            print("\n[DEBUG SUCCESS] Wizard sequence successfully fulfilled.")
            self.parent.after(500, self.parent.next_page)
            
        except Exception as e:
            print(f"\n[CRITICAL THREAD RUNTIME ERROR] Failed execution cascade block:\n{str(e)}")
            import traceback
            traceback.print_exc()
            messagebox.showerror("Installation Error", f"An error occurred during installation:\n{str(e)}")
            self.parent.show_page(1)

    def create_shortcut(self, target_exe, app_name):
        os_type = platform.system()
        desktop = os.path.join(os.path.expanduser("~"), "Desktop")
        print(f"[SHORTCUT DEBUG] Target desktop destination address mapped: {desktop}")

        if os_type == "Windows":
            try:
                from win32com.client import Dispatch
                shortcut_path = os.path.join(desktop, f"{app_name}.lnk")
                shell = Dispatch('WScript.Shell')
                shortcut = shell.CreateShortCut(shortcut_path)
                shortcut.Targetpath = target_exe
                shortcut.WorkingDirectory = os.path.dirname(target_exe)
                shortcut.save()
                print("[SHORTCUT DEBUG] Windows Shortcut built without exceptions.")
            except Exception as e:
                print(f"[SHORTCUT DEBUG ERROR] Windows shortcut creation failed: {e}")

        elif os_type == "Darwin":  # macOS
            shortcut_path = os.path.join(desktop, app_name)
            if os.path.exists(shortcut_path):
                os.remove(shortcut_path)
            try:
                os.symlink(target_exe, shortcut_path)
                print("[SHORTCUT DEBUG] MacOS Symlink created without exceptions.")
            except Exception as e:
                print(f"[SHORTCUT DEBUG ERROR] macOS symlink creation failed: {e}")

        elif os_type == "Linux":
            shortcut_path = os.path.join(desktop, f"{app_name}.desktop")
            try:
                with open(shortcut_path, "w") as f:
                    f.write(f"[Desktop Entry]\n"
                            f"Type=Application\n"
                            f"Name={app_name}\n"
                            f"Exec={target_exe}\n"
                            f"Terminal=false\n")
                os.chmod(shortcut_path, 0o755)
                print("[SHORTCUT DEBUG] Linux .desktop launcher file processed correctly.")
            except Exception as e:
                print(f"[SHORTCUT DEBUG ERROR] Linux shortcut creation failed: {e}")


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
        else:
            return os.getuid() == 0
    except:
        return False

if __name__ == "__main__":
    print("[INIT DEBUG] Checking startup state administrative privileges configuration...")
    if not is_admin():
        print("[INIT DEBUG] Not running with admin rights. Launching platform specific elevation prompt...")
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
            
    print("[INIT DEBUG] Confirmed admin access token context. Running GUI app container loop...")
    app = InstallerApp()
    app.mainloop()