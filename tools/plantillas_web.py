"""Descarga SOLO las plantillas de exportacion Web de Godot (sin bajar el paquete entero).

    python tools/plantillas_web.py <version> <carpeta_destino>
    python tools/plantillas_web.py 4.7.2 "%APPDATA%/Godot/export_templates/4.7.2.stable"

El paquete oficial de plantillas (`Godot_v<version>-stable_export_templates.tpz`)
es un zip de ~1,3 GB con las de TODAS las plataformas. Para exportar a web solo
hacen falta `web_nothreads_release.zip` y `web_nothreads_debug.zip` (unos MB):
se lee el indice del zip remoto con peticiones HTTP por rangos (`Range:`) y se
descargan solo esas dos entradas. Lo usa el workflow de GitHub para no bajar
1,3 GB en cada publicacion, y sirve igual en local.

Solo libreria estandar. Soporta zip normal y ZIP64.
"""

import struct
import sys
import urllib.request
import zlib
from pathlib import Path

QUIERO = ('web_nothreads_release.zip', 'web_nothreads_debug.zip')


def rango(url: str, inicio: int, fin: int) -> bytes:
    """Bytes [inicio, fin] (ambos incluidos) del fichero remoto."""
    req = urllib.request.Request(url, headers={'Range': f'bytes={inicio}-{fin}', 'User-Agent': 'plantillas-web'})
    with urllib.request.urlopen(req) as r:
        datos = r.read()
    if len(datos) != fin - inicio + 1:
        raise RuntimeError(f'el servidor no respeto el rango {inicio}-{fin} (llegaron {len(datos)} bytes)')
    return datos


def tamano(url: str) -> int:
    req = urllib.request.Request(url, method='HEAD', headers={'User-Agent': 'plantillas-web'})
    with urllib.request.urlopen(req) as r:
        return int(r.headers['Content-Length'])


def directorio_central(url: str, total: int) -> bytes:
    """El indice del zip: se busca el registro final (EOCD) en el ultimo trozo del fichero."""
    cola = rango(url, max(0, total - 70000), total - 1)
    pos = cola.rfind(b'PK\x05\x06')
    if pos < 0:
        raise RuntimeError('no se encuentra el final del zip')
    _, _, _, _, _, tam_cd, ofs_cd, _ = struct.unpack('<IHHHHIIH', cola[pos : pos + 22])
    if ofs_cd == 0xFFFFFFFF or tam_cd == 0xFFFFFFFF:
        # ZIP64: el localizador va justo antes del EOCD y apunta al registro ZIP64.
        loc = cola.rfind(b'PK\x06\x07', 0, pos)
        (ofs_eocd64,) = struct.unpack('<Q', cola[loc + 8 : loc + 16])
        eocd64 = rango(url, ofs_eocd64, ofs_eocd64 + 55)
        tam_cd, ofs_cd = struct.unpack('<QQ', eocd64[40:56])
    return rango(url, ofs_cd, ofs_cd + tam_cd - 1)


def entradas(cd: bytes):
    """(nombre, metodo, tam_comprimido, tam_real, offset_cabecera_local) de cada fichero."""
    i = 0
    while i + 46 <= len(cd) and cd[i : i + 4] == b'PK\x01\x02':
        metodo = struct.unpack('<H', cd[i + 10 : i + 12])[0]
        comp, real = struct.unpack('<II', cd[i + 20 : i + 28])
        n, x, c = struct.unpack('<HHH', cd[i + 28 : i + 34])
        ofs = struct.unpack('<I', cd[i + 42 : i + 46])[0]
        nombre = cd[i + 46 : i + 46 + n].decode('utf-8')
        extra = cd[i + 46 + n : i + 46 + n + x]
        # ZIP64: los campos a 0xFFFFFFFF van en el extra 0x0001, en este orden.
        j = 0
        while j + 4 <= len(extra):
            cab, lon = struct.unpack('<HH', extra[j : j + 4])
            if cab == 0x0001:
                vals = extra[j + 4 : j + 4 + lon]
                k = 0
                if real == 0xFFFFFFFF:
                    real = struct.unpack('<Q', vals[k : k + 8])[0]
                    k += 8
                if comp == 0xFFFFFFFF:
                    comp = struct.unpack('<Q', vals[k : k + 8])[0]
                    k += 8
                if ofs == 0xFFFFFFFF:
                    ofs = struct.unpack('<Q', vals[k : k + 8])[0]
            j += 4 + lon
        yield nombre, metodo, comp, real, ofs
        i += 46 + n + x + c


def extraer(url: str, metodo: int, comp: int, real: int, ofs: int) -> bytes:
    cab = rango(url, ofs, ofs + 29)
    n, x = struct.unpack('<HH', cab[26:30])
    inicio = ofs + 30 + n + x
    datos = rango(url, inicio, inicio + comp - 1)
    if metodo == 0:
        salida = datos
    elif metodo == 8:
        salida = zlib.decompress(datos, -15)
    else:
        raise RuntimeError(f'metodo de compresion {metodo} no soportado')
    if len(salida) != real:
        raise RuntimeError(f'tamano inesperado: {len(salida)} en vez de {real}')
    return salida


def main() -> None:
    version, destino = sys.argv[1], Path(sys.argv[2])
    url = f'https://github.com/godotengine/godot-builds/releases/download/{version}-stable/Godot_v{version}-stable_export_templates.tpz'
    # GitHub redirige a otro host: se resuelve una vez y se usa la URL final para los rangos.
    with urllib.request.urlopen(urllib.request.Request(url, method='HEAD', headers={'User-Agent': 'plantillas-web'})) as r:
        url = r.geturl()
    total = tamano(url)
    destino.mkdir(parents=True, exist_ok=True)
    encontradas = 0
    for nombre, metodo, comp, real, ofs in entradas(directorio_central(url, total)):
        base = nombre.rsplit('/', 1)[-1]
        if base in QUIERO:
            (destino / base).write_bytes(extraer(url, metodo, comp, real, ofs))
            print(f'{base}: {real / 1e6:.1f} MB')
            encontradas += 1
        elif base == 'version.txt':
            (destino / base).write_bytes(extraer(url, metodo, comp, real, ofs))
    if encontradas != len(QUIERO):
        raise SystemExit(f'solo se encontraron {encontradas} de {len(QUIERO)} plantillas web')
    print(f'plantillas web en {destino} (del paquete de {total / 1e9:.2f} GB, sin bajarlo entero)')


if __name__ == '__main__':
    main()
