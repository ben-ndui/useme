#!/bin/bash

# iOS Build Script with Progress Tracking
# Created by Claude Code

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Progress tracking
TOTAL_STEPS=6
CURRENT_STEP=0

print_header() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${WHITE}  🍎 iOS Build Script - Use Me   ${NC}"
    echo -e "${PURPLE}================================${NC}"
    echo ""
}

print_step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo -e "${CYAN}[${CURRENT_STEP}/${TOTAL_STEPS}] ${WHITE}$1${NC}"
    echo -e "${BLUE}▶ $2${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
    echo ""
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    echo -e "${RED}Build failed at step ${CURRENT_STEP}/${TOTAL_STEPS}${NC}"
    exit 1
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Start build process
print_header

# Step 1: Clean iOS dependencies
print_step "Nettoyage des dépendances iOS" "Suppression du Podfile.lock..."
if [ -f "ios/Podfile.lock" ]; then
    rm -rf ios/Podfile.lock
    print_success "Podfile.lock supprimé avec succès"
else
    print_warning "Podfile.lock introuvable (normal si première build)"
fi

# Step 2: Flutter clean and pub get
print_step "Nettoyage Flutter et récupération des packages" "fvm flutter clean && fvm flutter pub get"
if fvm flutter clean; then
    print_success "Flutter clean terminé"
else
    print_error "Erreur lors du flutter clean"
fi

if fvm flutter pub get; then
    print_success "Packages Flutter récupérés avec succès"
else
    print_error "Erreur lors de la récupération des packages Flutter"
fi

# Step 3: Flutter precache for iOS
print_step "Téléchargement des artefacts iOS" "fvm flutter precache --ios"
if fvm flutter precache --ios; then
    print_success "Artefacts iOS téléchargés avec succès"
else
    print_error "Erreur lors du téléchargement des artefacts iOS"
fi

# Step 4: Pod install
print_step "Installation des pods iOS" "cd ios && pod install"
cd ios || print_error "Impossible d'accéder au dossier ios/"

if pod install; then
    print_success "Pods iOS installés avec succès"
else
    print_error "Erreur lors de l'installation des pods iOS"
fi

# Return to root directory
cd ..

# Step 5: Flutter build iOS config
print_step "Configuration du build iOS" "fvm flutter build ios --config-only --release"
if fvm flutter build ios --config-only --release; then
    print_success "Configuration iOS générée avec succès"
else
    print_error "Erreur lors de la génération de la configuration iOS"
fi

# Step 6: Final verification
print_step "Vérification finale" "Contrôle des fichiers générés..."

# Check if important files exist
if [ -f "ios/Runner.xcworkspace/contents.xcworkspacedata" ]; then
    print_success "Workspace Xcode généré ✓"
else
    print_warning "Workspace Xcode non trouvé"
fi

if [ -d "ios/Pods" ]; then
    print_success "Dossier Pods créé ✓"
else
    print_warning "Dossier Pods non trouvé"
fi

# Final success message
echo -e "${PURPLE}================================${NC}"
echo -e "${GREEN}🎉 BUILD iOS TERMINÉ AVEC SUCCÈS!${NC}"
echo -e "${PURPLE}================================${NC}"
echo ""
echo -e "${WHITE}Prochaines étapes :${NC}"
echo -e "${CYAN}1. Ouvrir ios/Runner.xcworkspace dans Xcode${NC}"
echo -e "${CYAN}2. Sélectionner votre équipe de développement${NC}"
echo -e "${CYAN}3. Choisir votre appareil/simulateur${NC}"
echo -e "${CYAN}4. Appuyer sur le bouton Play pour lancer l'app${NC}"
echo ""
echo -e "${YELLOW}💡 Conseil: Utilisez Runner.xcworkspace (pas Runner.xcodeproj)${NC}"
echo ""