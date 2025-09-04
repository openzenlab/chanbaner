#!/bin/bash

echo "🧪 Running ChanBaner tests..."

# Test backend
echo "Testing backend API..."
cd backend
python test_api.py

# Test Flutter
echo "Testing Flutter app..."
cd ../flutter_app
flutter test

echo "✅ All tests completed"