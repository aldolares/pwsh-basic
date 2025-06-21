import os
import random
from PIL import Image, ImageDraw, ImageFont

# Listas de animales y adjetivos
ANIMALES = [
    "aguila", "caballo", "conejo", "delfin", "elefante", "gato", "leon", "lobo", "oso", "perro", "tigre", "zorro"
]
ADJETIVOS = [
    "amable", "bravo", "curioso", "fuerte", "grande", "jugueton", "lento", "rapido", "ruidoso", "silencioso", "suave", "torpe", "valiente", "feliz", "leal", "feroz", "listo"
]

# Parámetros de la imagen
dir_destino = os.path.join(os.path.dirname(__file__), "../02_Imagenes")
ALTO_IMAGEN = 100
ALTO_NUMERO = 80
MARGEN_X = 10

# Fuente (usa una fuente estándar del sistema)
def get_font(size):
    # Ajusta el tamaño de la fuente para que el número ocupe 80px de alto real
    try:
        font_path = "arial.ttf"
        font = ImageFont.truetype(font_path, size)
    except:
        font = ImageFont.load_default()
    # Ajustar el tamaño de la fuente para que el número ocupe ALTO_NUMERO px
    test_img = Image.new("RGB", (200, 200))
    draw = ImageDraw.Draw(test_img)
    text = "888"  # Usar un número de 3 dígitos para referencia
    bbox = draw.textbbox((0, 0), text, font=font)
    actual_height = bbox[3] - bbox[1]
    # Si la altura no es la esperada, ajustar
    if actual_height == 0:
        return font
    scale = ALTO_NUMERO / actual_height
    new_size = max(1, int(size * scale))
    try:
        font = ImageFont.truetype(font_path, new_size)
    except:
        font = ImageFont.load_default()
    return font

def crear_imagen(nombre, numero, formato="jpg"):
    font = get_font(ALTO_NUMERO)
    # Medir el ancho del número usando textbbox
    dummy_img = Image.new("RGB", (1, 1))
    draw = ImageDraw.Draw(dummy_img)
    bbox = draw.textbbox((0, 0), str(numero), font=font)
    ancho_num = bbox[2] - bbox[0]
    ancho_img = ancho_num + 2 * MARGEN_X
    img = Image.new("RGB", (ancho_img, ALTO_IMAGEN), color="white")
    draw = ImageDraw.Draw(img)
    # Centrar el número verticalmente
    y = (ALTO_IMAGEN - ALTO_NUMERO) // 2
    draw.text((MARGEN_X, y), str(numero), font=font, fill="black")
    ext = "jpg" if formato.lower() == "jpg" else "png"
    file_format = "JPEG" if formato.lower() == "jpg" else "PNG"
    img.save(os.path.join(dir_destino, f"{nombre}.{ext}"), format=file_format)

def main():
    import sys
    os.makedirs(dir_destino, exist_ok=True)
    # Leer cantidad y porcentaje desde argumentos de línea de comandos
    if len(sys.argv) > 1:
        try:
            cantidad = int(sys.argv[1])
        except ValueError:
            print("El primer parámetro debe ser un número entero. Usando 10 por defecto.")
            cantidad = 10
    else:
        cantidad = 10  # Valor por defecto
    if len(sys.argv) > 2:
        try:
            porcentaje_jpg = float(sys.argv[2])
            if not (0 <= porcentaje_jpg <= 1):
                raise ValueError
        except ValueError:
            print("El segundo parámetro debe ser un número decimal entre 0 y 1. Usando 0.5 por defecto.")
            porcentaje_jpg = 0.5
    else:
        porcentaje_jpg = 0.5  # Valor por defecto
    usados = set()
    cantidad_jpg = int(round(cantidad * porcentaje_jpg))
    cantidad_png = cantidad - cantidad_jpg
    formatos = ["jpg"] * cantidad_jpg + ["png"] * cantidad_png
    random.shuffle(formatos)
    for formato in formatos:
        animal = random.choice(ANIMALES)
        adjetivo = random.choice(ADJETIVOS)
        numero = random.randint(100, 999)
        nombre = f"{animal}_{adjetivo}_{numero}"
        # Evitar duplicados
        while nombre in usados:
            animal = random.choice(ANIMALES)
            adjetivo = random.choice(ADJETIVOS)
            numero = random.randint(100, 999)
            nombre = f"{animal}_{adjetivo}_{numero}"
        usados.add(nombre)
        crear_imagen(nombre, numero, formato)
    print(f"{cantidad} imágenes generadas en {dir_destino} ({cantidad_jpg} JPG, {cantidad_png} PNG)")

if __name__ == "__main__":
    main()
