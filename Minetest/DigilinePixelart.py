# Script to automatically generate pixelart on one or more matrix screens

import sys
import math
import pprint
import argparse
from PIL import Image, ImageOps

class MatrixImageConverter:
    def __init__(self, image_path, size, threshold):
        self.image_path = image_path
        self.size = size
        self.threshold = threshold
        
    # Loads the image using Pillow and returns the image scaled to the desired size (Pillow object)
    def load_image(self):
        image = Image.open(self.image_path)
        return ImageOps.fit(image, self.size)

    # Returns the respective color value (black or white) based on the given threshold value
    def calculate_threshold(self, value, invert=False):
        if value > self.threshold:
            return 255 if invert == False else 0
        else:
            return 0 if invert == False else 255

    # Convert a given image to black and white levels and then execute the given lambda function for each pixel, which breaks the color values down to 255 or 0
    def convert_to_dualtone(self, image, invert=False):
        return image.convert("L").point(lambda x: self.calculate_threshold(x, invert=invert), mode="1") 

    # Writes the image data (pixel values) divided into blocks of 16 into a Python dictionary
    def generate_matrix_data(self, image):
        width, height = image.size
        data = {}
        for chunk_x in range(math.ceil(width / 16)):
            for chunk_y in range(math.ceil(height / 16)):
                chunk_image = image.crop((16 * chunk_x, 16 * chunk_y, (chunk_x + 1) * 16, (chunk_y + 1) * 16)) # Crop from the original image, see https://www.geeksforgeeks.org/python-pil-image-crop-method/
                matrix_screen = {}
                for x in range(16):
                    for y in range(16):
                        # Pass the x & y to the .getpixel method in reverse order, otherwise the individual matrixscreens are rotated by 90 or 180 degrees (perhaps due to the crop?).
                        matrix_screen[(y + 1, x + 1)] = 1.0 if chunk_image.getpixel((y, x)) == 255 else 0.0
                # Turple as index
                data[(chunk_x + 1, chunk_y + 1)] = matrix_screen
        #pprint.pprint(data)
        return data

    # Assembles the actual luac-code from the data extracted from generate_matrix_data
    def generate_luac_code(self, data):
        lua_codes = []
        for screen, matrix_screen in data.items():
            lua_code = f"digiline_send(\"{screen[0]}{screen[1]}\", {{"
            for x in range(16):
                # Add +1 to the index, as the range is only from 0-15.
                lua_code += "{" + ",".join(str(matrix_screen[(y+1, x+1)]) for y in range(16)) + "},"
            # Remove last comma
            lua_code = lua_code[:-1] + "})"
            lua_codes.append(lua_code)
        return lua_codes

    # Chronological processing of data
    def process_image(self):
        image = self.load_image()
        dualtone_image = self.convert_to_dualtone(image, args.color)
        matrix_data = self.generate_matrix_data(dualtone_image)
        lua_codes = self.generate_luac_code(matrix_data)
        return lua_codes

if __name__ == "__main__":
    # CLI-Argument-Parser
    parser = argparse.ArgumentParser(description="Create Imagecode that can be displayed on matrix screens", epilog="By Aurelium staff")
    parser.add_argument("-i", "--image", required=True, metavar="IMAGE PATH", type=str, help="Path to the image to be displayed")
    parser.add_argument("-x", "--width", required=True, type=int, help="Width of the matrix screen array")
    parser.add_argument("-y", "--height", required=True, type=int, help="Height of the matrix screen array")
    parser.add_argument("-t", "--threshold", default=200, type=int, help="Color threshold for monochrome conversion")
    parser.add_argument("-n", "--nobase", action="store_true", help="Ignore Base 16 - Might leave a lot of black areas.")
    parser.add_argument("-c", "--color", action="store_true", help="Inverts the color")
    parser.add_argument("-s", "--save", action="store_true", help="saves the luac-code in pwd")
    parser.add_argument("-q", "--quiet", action="store_true", help="Dont print luac-code")
    args = parser.parse_args()

    # Check whether height and width are divisible by 16
    if (args.width % 16 != 0 or args.height % 16 != 0) and not args.nobase:
        raise ArithmeticError("[ERROR] Width or Height is not divisible by 16\n\nTry with -n or --nobase!")
        

    converter = MatrixImageConverter(args.image, (args.width, args.height), args.threshold)
    lua_codes = converter.process_image()
    
    print("Example layout for matrix screens:")
    print("e.g 34 correspondes to column 3 and row 4, 12 corresponds to column 1 and row 2 and so on..")
    print(" ⭡ -----------------------------")
    print(" | |      |      |      |      |")
    print(" | |  11  |  21  |  31  |  41  |")
    print(" | |      |      |      |      |")
    print(" | -----------------------------")
    print(" | |      |      |      |      |")
    print(" x |  12  |  22  |  32  |  42  |")
    print(" | |      |      |      |      |")
    print(" | -----------------------------")
    print(" | |      |      |      |      |")
    print(" | |  13  |  23  |  33  |  43  |")
    print(" | |      |      |      |      |")
    print(" | -----------------------------")
    print(" ⭣ ⭠-------------y------------⭢")
    input("Press any button to continue..")
    print(f"\nMatrixscreens needed: {math.ceil(args.width / 16)*math.ceil(args.height / 16)}")
    input("Press any button to continue..")
    
    if not args.quiet:
        for code in lua_codes:
            print(code)

    if args.save:
        filename = f"{args.image}-w.{args.width}-h.{args.height}-c.{args.color}-t.{args.threshold}.luac"
        try:
            with open(filename, "w") as f:
                header = f"""
                    --[[
                    Autogenerated LED-Control for matrixscreens using {sys.argv[0]}

                    Example layout for matrix screens:
                    e.g 34 correspondes to column 3 and row 4, 12 corresponds to column 1 and row 2 and so on..
                    ⭡ -----------------------------
                    | |      |      |      |      |
                    | |  11  |  21  |  31  |  41  |
                    | |      |      |      |      |
                    | -----------------------------
                    | |      |      |      |      |
                    x |  12  |  22  |  32  |  42  |
                    | |      |      |      |      |
                    | -----------------------------
                    | |      |      |      |      |
                    | |  13  |  23  |  33  |  43  |
                    | |      |      |      |      |
                    | -----------------------------
                    ⭣ ⭠-------------y------------⭢
                    
                    Requirements {math.ceil(args.width / 16)*math.ceil(args.height / 16)}
                    ]]
                    """

                f.write((header+"\n\n".join(code for code in lua_codes)))
                print(f"Saved luac-code to {filename} successfully")
        except:
            raise OSError("Could not save luac-code to file!")

            
