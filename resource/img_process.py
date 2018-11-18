from PIL import Image
import argparse
import math
parser = argparse.ArgumentParser(description='Convert normal RGB pictures for Basys 3 4-bit RGB')
parser.add_argument('img_path', type=str, help='path to the image that you want to convert')
parser.add_argument('rom_name', type=str, help='the name of the rom module')
parser.add_argument('--width', type=int, help='new width', default=None)
parser.add_argument('--height', type=int, help='new height', default=None)
parser.add_argument('--mono', action='store_true', help='apply further compression if the picture is monochromic', default=False)
parser.add_argument('--file', type=str, help='save output to file')
args = parser.parse_args()

def bin_rom(rom_name, total, x_high, y_high, bin_file):
    template = """
    module {}(clk, video_on, x, y, color);
    parameter ROM_WIDTH = 12;
    parameter ROM_ADDR_BITS = {};

    (* rom_style="block" *)
    reg [ROM_WIDTH-1:0] rom [(2**ROM_ADDR_BITS)-1:0];
    input wire clk;
    input wire video_on;
    input wire [{}:0] x;
    input wire [{}:0] y;
    reg [ROM_ADDR_BITS-1:0] address;
    output reg [ROM_WIDTH-1:0] color;

    initial
      $readmemh("{}", rom);

    always @(posedge clk)
      if (video_on) begin
         address <= {{y, x}};
         color <= rom[address];
      end
    endmodule
    """.format(rom_name, total, x_high, y_high, bin_file)
    return template

def main():
    lines = []
    im = Image.open(args.img_path)
    width = args.width
    height = args.height
    if width is not None and height is not None:
        im = im.resize((width, height))
    w, h = im.size
    y_digits = math.ceil(math.log2(h))
    x_digits = math.ceil(math.log2(w))
    total =  y_digits + x_digits
    y_high = y_digits - 1
    x_high = x_digits - 1
    if args.mono:
        for y in range(h):
            for x in range(w):
                concat_bin = ('{0:0' + str(y_digits) + 'b}{1:0' + str(x_digits) + 'b}').format(y,x)
                lines.append(('@{0:x}').format(int(concat_bin, 2)))
                r, g, b = im.getpixel((x, y))

                if (r + g + b) >= 225 * 3:
                    lines.append('1')
                else:
                    lines.append('0')
    else:
        for y in range(h):
            for x in range(w):
                r, g, b = im.getpixel((x, y))
                r = r // 16
                g = g // 16
                b = b // 16
                
                concat_bin = ('{0:0' + str(y_digits) + 'b}{1:0' + str(x_digits) + 'b}').format(y,x)
                lines.append(('@{0:x}').format(int(concat_bin, 2)))
                lines.append('{0:x}{1:x}{2:x}'.format(r, g, b))
    if args.file is not None:
        with open(args.file, 'w') as f:
            for line in lines:
                f.write(line + '\n')
        with open(args.file + '.v', 'w') as f:
            f.write(bin_rom(args.rom_name, total, x_high, y_high, args.file))
    else:
        for line in lines:
            print(line)

if __name__ == '__main__':
    main()
