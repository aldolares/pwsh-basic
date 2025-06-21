import sys
import os
import random
import string

ANIMALS = [
    "gato", "perro", "elefante", "leon", "tigre", "oso", "zorro", "conejo", "lobo", "jirafa",
    "raton", "caballo", "vaca", "mono", "panda", "koala", "delfin", "tortuga", "aguila", "halcon"
]
ADJECTIVES = [
    "feliz", "rapido", "lento", "fuerte", "suave", "bravo", "pequeno", "grande", "listo", "torpe",
    "amable", "feroz", "tranquilo", "ruidoso", "silencioso", "valiente", "curioso", "leal", "astuto", "jugueton"
]
LOREM = (
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
    "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. "
    "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. "
    "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. "
)

def random_filename(existing):
    while True:
        animal = random.choice(ANIMALS)
        adj = random.choice(ADJECTIVES)
        num = f"{random.randint(0, 999):03d}"
        name = f"{animal}_{adj}_{num}.txt"
        if name not in existing:
            return name

def main():
    if len(sys.argv) != 3:
        print("Uso: python3 createfiles.py <cantidad_archivos> <porcentaje_mayores_1024>")
        sys.exit(1)
    try:
        total = int(sys.argv[1])
        percent = float(sys.argv[2])
        if not (0 <= percent <= 1):
            raise ValueError
    except ValueError:
        print("Argumentos inválidos. El porcentaje debe estar entre 0 y 1.")
        sys.exit(1)

    n_big = int(total * percent)
    n_small = total - n_big
    sizes = [random.randint(1025, 2048) for _ in range(n_big)] + [random.randint(0, 1024) for _ in range(n_small)]
    random.shuffle(sizes)

    used_names = set()
    # Obtener la ruta absoluta a la carpeta 01_Listado en la raíz del proyecto
    output_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '01_Listado'))
    os.makedirs(output_dir, exist_ok=True)
    for size in sizes:
        fname = random_filename(used_names)
        used_names.add(fname)
        fname_with_size = fname.replace('.txt', f'_{size}b.txt')
        content = (LOREM * ((size // len(LOREM)) + 1))[:size]
        with open(os.path.join(output_dir, fname_with_size), "w", encoding="utf-8") as f:
            f.write(content)
    print(f"{total} archivos generados en la carpeta '01_Listado'.")

if __name__ == "__main__":
    main()
