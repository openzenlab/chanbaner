#!/bin/bash

echo "🧘 Setting up ChanBaner MVP..."

# Backend setup
echo "📦 Setting up backend..."
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
echo "✅ Backend dependencies installed"

# Flutter setup
echo "📱 Setting up Flutter app..."
cd ../flutter_app
flutter pub get
echo "✅ Flutter dependencies installed"

# Make scripts executable
chmod +x ../backend/run.sh
chmod +x ../scripts/*.sh

echo "🎉 Setup complete!"
echo ""
echo "To start the backend:"
echo "  cd backend && ./run.sh"
echo ""
echo "To start the Flutter app:"
echo "  cd flutter_app && flutter run"
echo ""
echo "To test the API:"
echo "  cd backend && python test_api.py"