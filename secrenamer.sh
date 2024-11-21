
if [ -z "$1"]; then
    DIRECTORIO="$(pwd)"
else
    DIRECTORIO=$1
fi
#rename 's/\(UT[0-9]{4}MX\) //' "$DIRECTORIO"
#find "$DIRECTORIO" -type f ! -iname "*.mp3" -exec rm -f {} +
#find "$DIRECTORIO" -type f -iname "*.mp3" -exec rename 's/\.mp3$/.mp3/i' {} +
find "$DIRECTORIO" -type f -name "*.mp3" -exec rename 's/ - a1 - / - /' {} +
find "$DIRECTORIO" -type f -name "*.mp3" -exec rename 's/ - a2 - / - /' {} +
find "$DIRECTORIO" -type f -name "*.mp3" -exec rename 's/ - b1 - / - /' {} +
find "$DIRECTORIO" -type f -name "*.mp3" -exec rename 's/ - b2 - / - /' {} +
find "$DIRECTORIO" -type f -name "*.mp3" -exec rename 's/ - a -/ - /' {} +
find "$DIRECTORIO" -type f -name "*.mp3" -exec rename 's/ - b -/ - /' {} +
find "$DIRECTORIO" -type f -name "*.mp3" -exec rename 's/_-_/ - /' {} +
find "$DIRECTORIO" -type f -name "*.mp3" -exec rename 's/_/ /' {} +
find "$DIRECTORIO" -type f -name "*.mp3" -exec rename 's/-bc//' {} +
find "$DIRECTORIO" -type f -name "*.mp3" -exec rename 's/-nrg//' {} +
find "$DIRECTORIO" -type f -name "*.mp3" -exec rename 's/-mtc//' {} +
find "$DIRECTORIO" -type f -name "*.mp3" -exec rename 's/-vmc//' {} +
find "$DIRECTORIO" -type f -name "*.mp3" -exec rename 's/-puta//' {} +
find "$DIRECTORIO" -type f -name "*.mp3" -exec rename 's/-ass//' {} +
find "$DIRECTORIO" -type f -name "*.mp3" -exec rename 's/-ovm//' {} +
find "$DIRECTORIO" -type f -name "*.mp3" -exec rename 's/-bnp//' {} +
find "$DIRECTORIO" -type f -name "*.mp3" -exec rename 's/-bwa//' {} +
find "$DIRECTORIO" -type f -name "*.mp3" -exec rename 's/-sq//' {} +
find "$DIRECTORIO" -type f -name "*.mp3" -exec rename 's/-idc//' {} +
find "$DIRECTORIO" -type f -name "*.mp3" -exec rename 's/dj celtic - dj xavo/Dj Celtic & Dj Xavo/' {} +
#find "$DIRECTORIO" -type f -name "*.mp3" -exec rename 's/_/ /' {} +