import os
import sys
import shutil
import zipfile
import platform
import threading
import requests
import customtkinter as ctk
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

        home = os.path.expanduser("~")
        if platform.system() == "Windows":
            self.download_url = "https://github.com/user/repo/archive/refs/tags/windows/v1.0.0.zip" 
        elif platform.system() == "Darwin":
            self.download_url = "https://github.com/user/repo/archive/refs/tags/mac/v1.0.0.zip" 
        else:
            self.download_url = "https://github.com/user/repo/archive/refs/tags/linux/v1.0.0.zip" 
        
        # Configuration Variables
        # Replace with your GitHub Release URL
        self.target_folders = ["canvas.zip/", "control_panel.zip/"]  # Relative paths inside the ZIP to extract
        
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
            target_dir = self.parent.install_dir.get()
            zip_tmp_path = os.path.join(os.path.expanduser("~"), "installer_tmp.zip")
            
            # Step 1: Download
            self.update_status("Connecting to GitHub releases...", 5)
            response = requests.get(self.parent.download_url, stream=True)
            response.raise_for_status()
            
            total_length = response.headers.get('content-length')
            
            with open(zip_tmp_path, "wb") as f:
                if total_length is None: # No content length header
                    f.write(response.content)
                else:
                    downloaded = 0
                    total_length = int(total_length)
                    for chunk in response.iter_content(chunk_size=4096):
                        downloaded += len(chunk)
                        f.write(chunk)
                        # Map download to 10% - 70% of total progress bar
                        percentage = 10 + int(60 * (downloaded / total_length))
                        self.update_status(f"Downloading packages: {downloaded // 1024} KB received", percentage)

            # Step 2: Extraction
            self.update_status("Extracting specific folders...", 75)
            os.makedirs(target_dir, exist_ok=True)
            
            with zipfile.ZipFile(zip_tmp_path, 'r') as zip_ref:
                for member in zip_ref.namelist():
                    # Check if entry is within specified sub-folders
                    if any(member.startswith(folder) for folder in self.parent.target_folders):
                        zip_ref.extract(member, target_dir)
            
            # Clean up the zip file
            if os.path.exists(zip_tmp_path):
                os.remove(zip_tmp_path)

            # Step 3: Handle Shortcut
            if self.parent.create_shortcut_var.get():
                self.update_status("Creating desktop shortcuts...", 90)
                # Assuming your executable binary is located inside folder1 named 'app_run'
                # Adjust this relative path depending on your repo structure
                exe_relative_path = os.path.join(self.parent.target_folders[0], "app_run") 
                exe_absolute_path = os.path.join(target_dir, exe_relative_path)
                self.create_shortcut(exe_absolute_path, "MyCustomApp")
                
            self.update_status("Installation complete!", 100)
            self.parent.after(500, self.parent.next_page)
            
        except Exception as e:
            messagebox.showerror("Installation Error", f"An error occurred during installation:\n{str(e)}")
            self.parent.show_page(1) # Send them back to target folder path configurations

    def create_shortcut(self, target_exe, app_name):
        os_type = platform.system()
        desktop = os.path.join(os.path.expanduser("~"), "Desktop")

        if os_type == "Windows":
            import winshell
            from win32com.client import Dispatch
            try:
                shortcut_path = os.path.join(desktop, f"{app_name}.lnk")
                shell = Dispatch('WScript.Shell')
                shortcut = shell.CreateShortCut(shortcut_path)
                shortcut.Targetpath = target_exe
                shortcut.WorkingDirectory = os.path.dirname(target_exe)
                shortcut.save()
            except Exception as e:
                print(f"Windows shortcut creation failed: {e}")

        elif os_type == "Darwin":  # macOS
            shortcut_path = os.path.join(desktop, app_name)
            if os.path.exists(shortcut_path):
                os.remove(shortcut_path)
            os.symlink(target_exe, shortcut_path)

        elif os_type == "Linux":
            shortcut_path = os.path.join(desktop, f"{app_name}.desktop")
            with open(shortcut_path, "w") as f:
                f.write(f"[Desktop Entry]\n"
                        f"Type=Application\n"
                        f"Name={app_name}\n"
                        f"Exec={target_exe}\n"
                        f"Terminal=false\n")
            os.chmod(shortcut_path, 0o755)


class SuccessPage(ctk.CTkFrame):
    def __init__(self, parent):
        super().__init__(parent)
        
        label = ctk.CTkLabel(self, text="Installation Successful!", font=("Arial", 24, "bold"), text_color="green")
        label.pack(pady=(60, 20))
        
        desc = ctk.CTkLabel(self, text="The application was installed successfully on your computer.\nClick Finish to exit the wizard.", font=("Arial", 14))
        desc.pack(pady=20)
        
        btn_finish = ctk.CTkButton(self, text="Finish", command=parent.destroy)
        btn_finish.pack(side="bottom", anchor="se", padx=30, pady=30)


if __name__ == "__main__":
    app = InstallerApp()
    app.mainloop()