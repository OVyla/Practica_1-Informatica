#!/bin/bash

#Oriol Vilà i Laia Espluga

echo "Opcions disponibles:"
echo "q - Sortir de l'aplicació"
echo "lp - Llistar per pantalla els països i el seu codi"
echo "sc - Seleccionar un país"
echo "se - Seleccionar un estat"
echo "le - Llistar els estats/províncies del país seleccionat"
echo "lcp - Llistar el wikidatald i les poblacions del país seleccionat"
echo "ecp - Guardar el wikidatald i les poblacions del país seleccionat en un arxiu"
echo "lce - Llistar el Wikidata de l'estat seleccionat"
echo "ece - Buscar el Wikidata de l'estat seleccionat i guardar-lo en un fitxer"
echo "gwd - Guardar en un fitxer les dades de població del seu WikiData"
echo "est - Mostrar les estadístiques del dataset"
#Mostrar un menú amb les opcions

while [ "$opcio" != "q" ]; do
    read -p "Escull una opcio: " opcio
    case $opcio in
        "q") #Comanda per sortir del programa
            echo "Sortint de l'aplicació"
            exit 0
            ;;
        "lp") #Comanda per llistar per pantalla els països i el seu codi
            awk -F ',' '{ if (seen[$8] == 0) { print $7, $8; seen[$8] = 1; } }' cities.csv
            ;;
        "sc") #Comanda per demanar a l'usuari un país. El codi del país s'emmagatzema en una variable codi_pais
            read -p "Introdueix el nom del país (entre comes si és un nom compost): " nom_pais #Demanar nom del país
            codi_pais=$(awk -F ',' -v nom="$nom_pais" '{ if (seen[$8] == 0 && $8 == nom) {print $7; seen[$8] = 1; } }' cities.csv) #Buscar i emmagatzemar el codi del país buscant el nom del pais
            num_pais=$(awk -F ',' -v nom="$nom_pais" '{ if (seen[$8] == 0 && $8 == nom) {print $6; seen[$8] = 1; } }' cities.csv) #Buscar i emmagatzemar el numero del país per fer futures comporvacions
            if [ -z "$codi_pais" ]; then
                codi_pais="XX" #Si el nom del país no es troba o no és vàlid, el seu codi val "XX"
            fi
            echo $codi_pais
            ;;
        "se") #Comanda per demanar a l'usuari un estat. El codi de l'estat s'emmagatzema en una variable codi_estat
            read -p "Introdueix el nom de l'estat (entre comes si és un nom compost): " nom_estat #Demanar nom del estat
            codi_estat=$(awk -F ',' -v nom="$nom_estat" '{ if (seen[$5] == 0 && $5 == nom) {print $4; seen[$5] = 1; } }' cities.csv) #Buscar i emmagatzemar el codi del estat buscant el nom del estat
            num_estat=$(awk -F ',' -v nom="$nom_estat" '{ if (seen[$5] == 0 && $5 == nom) {print $6; seen[$5] = 1; } }' cities.csv) #Buscar i emmagatzemar el numero del estat per fer futures comporvacions
            if [ -z "$codi_estat" ]; then
                codi_estat="XX" #Si el nom del estat no es troba o no és vàlid, el seu codi val "XX"
            fi

            if [ "$codi_pais" == "XX" ] || [ "$num_estat" != "$num_pais" ]; then
                echo "El país i l'estat seleccionats no coincideixen. Introdueix els noms correctes." #Si el nombre de l'estat no correspon amb el nombre del país (l'estat no pertany al país), el codi de l'estat val "XX"
            	codi_estat="XX"
            else
                echo $codi_estat
            fi
            ;;
        "le") #Comanda per llistar els estats/províncies del país prèviament seleccionat (var codi_pais)
            if [ -z "$codi_pais" ]; then
                echo "Abans de llistar els estats, has de seleccionar un país amb l'ordre 'sc'." #Mostrar un avís si no s'ha seleccionat cap país
            else
                awk -F ',' -v pais="$codi_pais" '{ if (seen[$5] == 0 && $7 == pais) {print $4, $5; seen[$5] = 1; } }' cities.csv #Buscar i mostrar cada estat/provincia que estigui dins del país seleccionat
            fi
            ;;
        "lcp") #Comanda per llistar el wikidatald i les poblacions del país seleccionat
            if [ -z "$codi_pais" ]; then
                echo "Abans de llistar el wikidatald, has de seleccionar un país amb l'ordre 'sc'." #Mostrar un avís si no s'ha seleccionat cap país
            else
                awk -F ',' -v pais="$codi_pais" '{ if (seen[$5] == 0 && $7 == pais) {print $5, $11; seen[$5] = 1; } }' cities.csv #Buscar i mostrar les poblacions amb el seu wikidatald que estiguin dins del país seleccionat
            fi
            ;;
        "ecp") #Comanda per guardar en un arxiu (<codi_pais>.csv) el wikidatald i les poblacions del país seleccionat
            if [ -z "$codi_pais" ]; then
                echo "Abans de llistar el wikidatald, has de seleccionar un país amb l'ordre 'sc'." #Mostrar un avís si no s'ha seleccionat cap país
            else
                awk -F ',' -v pais="$codi_pais" '{ if (seen[$5] == 0 && $7 == pais) {print $5, $11; seen[$5] = 1; } }' cities.csv > "$codi_pais.csv" #Buscar les poblacions amb el seu wikidatald que estiguin dins del país seleccionat i guardar-ho en l'arxiu
            fi
            ;;
        "lce")  # Comanda per llistar el Wikidata de l'estat seleccionat
            if [ -z "$codi_estat" ]; then
                echo "Abans de llistar el wikidata, has de seleccionar un estat amb l'ordre 'se'." #Mostrar un avís si no s'ha seleccionat cap estat
            else
                awk -F ',' -v estat="$codi_estat" -v pais="$codi_pais" '$4 == estat && $7 == pais {print $2, $11}' cities.csv #Buscar i mostrar amb el codi de l'estat i en nombre del país, les poblacions que coincideixin i el seu wikidatald
            fi
            ;;
        "ece") # Comanda per buscar el Wikidata de l'estat seleccionat i guardar-lo en un fitxer (<codi_pais>_<codi_estat>.csv)
            if [ -z "$codi_estat" ]; then
                echo "Abans de llistar el wikidata, has de seleccionar un estat amb l'ordre 'se'." #Mostrar un avís si no s'ha seleccionat cap estat
            else
                awk -F ',' -v estat="$codi_estat" -v pais="$codi_pais" '$4 == estat && $7 == pais {print $2, $11}' cities.csv > "${codi_pais}_${codi_estat}.csv" #Buscar amb el codi de l'estat i en nombre del país, les poblacions que coincideixin i el seu wikidatald i guardar-ho en l'arxiu
            fi
            ;;
        "gwd") #Comanda per demanar el nom d'una població. Si aquesta té wikidatald, pertany al país i a l'estat/província, extreu les dades de la població (del wikidata) i les emmagatzema en un arxiu (<wikidataId>.json)
			read -p "Introdueix el nom de la població (entre comes si és un nom compost): " nom_poblacio
			wikidataId=$(awk -F ',' -v poblacio="$nom_poblacio" -v estat="$codi_estat" '$2 == poblacio && $4 == estat {print $11}' cities.csv) #Si la poblacio coincideix amb l'estat seleccionat i amb el nom de la poblacio, guarda al WikidataId en una variable (WikidataId)
			wikidataUrl="https://www.wikidata.org/wiki/Special:EntityData/$wikidataId.json" #Busca al web les dades de la població (utilitznat la variable WikidataId en funció de la població/estat)
			curl -o "$wikidataId.json" "$wikidataUrl" #Utilitza la comanda curl per descarregar la informació en format JSON
			;;
        "est") # Comanda per obtenir estadístiques (tot i que la comanda és correcta, aparentment no funciona correctament)
            nord=0
            sud=0
            est=0
            oest=0
            no_ubic=0
            no_wdid=0

            awk -F ',' '{
                nord += ( $9 > 0.0 )
                sud += ( $9 < 0.0 )
                est += ( $10 > 0.0 )
                oest += ( $10 < 0.0 )
                no_ubic += ( $9 == 0 ) && ( $10 == 0 )
                no_wdid += ( $11 == "" )
            } 
            END {
                printf "Nord %d Sud %d Est %d Oest %d No ubic %d No WDId %d\n", nord, sud, est, oest, no_ubic, no_wdid
            }' cities.csv
            ;;
			*) #Mostrar un missatge en el cas de que l'usuari introdueixi una comanda no vàlida
            echo "Opció no vàlida"
            ;;
    esac
done
