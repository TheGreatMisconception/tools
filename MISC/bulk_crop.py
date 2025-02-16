import os
import argparse
from PIL import Image

class ImageCropper:
    def __init__(self, width=None, height=None, inplace=False, suffix='_cropped', input_dir=''):
        self.width = width
        self.height = height
        self.inplace = inplace
        self.suffix = suffix
        self.input_dir = input_dir

    def crop_images(self):
        for filename in os.listdir(self.input_dir):
            if filename.lower().endswith(('.png', '.jpg', '.jpeg', '.bmp', '.gif')):
                img_path = os.path.join(self.input_dir, filename)
                self.process_image(img_path, filename)

    def process_image(self, img_path, filename):
        with Image.open(img_path) as img:e
            if self.width is not None and self.height is not None:
                left = (img.width - self.width) // 2
                top = (img.height - self.height) // 2
                right = left + self.width
                bottom = top + self.height
                new_img = img.crop((left, top, right, bottom))
            elif self.width is not None:
                new_img = img.crop((0, 0, self.width, img.height))
            elif self.height is not None:
                new_img = img.crop((0, 0, img.width, self.height))
            else:
                new_img = img

            if self.inplace:
                new_img.save(img_path)
            else:
                new_filename = f"{os.path.splitext(filename)[0]}{self.suffix}{os.path.splitext(filename)[1]}"
                new_img.save(os.path.join(self.input_dir, new_filename))
            print(f"Processed: {filename}")

def main():
    parser = argparse.ArgumentParser(description='Crop images in bulk.')
    parser.add_argument('--width', type=int, help='Width of the cropped image')
    parser.add_argument('--height', type=int, help='Height of the cropped image')
    parser.add_argument('--inplace', action='store_true', help='Crop images in place')
    parser.add_argument('--suffix', type=str, default='_cropped', help='Suffix for cropped images')
    parser.add_argument('--input_dir', type=str, required=True, help='Directory containing images to crop')

    args = parser.parse_args()

    cropper = ImageCropper(args.width, args.height, args.inplace, args.suffix, args.input_dir)
    cropper.crop_images()

if __name__ == '__main__':
    main()
