docker stop kabob-virtuoso-HUMAN
docker rm kabob-virtuoso-HUMAN
docker rm virtuoso-data-HUMAN
./scripts/virtuoso-specific-scripts/step2_virtuoso-setup.sh HUMAN
docker exec -ti kabob-virtuoso-HUMAN bash



