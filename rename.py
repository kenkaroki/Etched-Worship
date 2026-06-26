import os

def rename_images(folder_path):
    # Supported image extensions
    image_extensions = {
        '.jpg', '.jpeg', '.png', '.gif', '.bmp',
        '.webp', '.tiff', '.tif'
    }

    # Get all image files
    image_files = [
        f for f in os.listdir(folder_path)
        if os.path.isfile(os.path.join(folder_path, f))
        and os.path.splitext(f)[1].lower() in image_extensions
    ]

    # Sort files for consistent numbering
    image_files.sort()

    # Rename images
    for index, filename in enumerate(image_files, start=1):
        old_path = os.path.join(folder_path, filename)
        extension = os.path.splitext(filename)[1].lower()
        new_name = f"background-image-{index}{extension}"
        new_path = os.path.join(folder_path, new_name)

        os.rename(old_path, new_path)
        print(f"Renamed: {filename} -> {new_name}")

    print(f"\nDone! Renamed {len(image_files)} image(s).")

if __name__ == "__main__":
    folder = input("Enter the folder path: ").strip().strip('"')
    rename_images(folder)