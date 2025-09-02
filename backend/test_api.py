#!/usr/bin/env python3
"""
Test script for Koan Orchestrator API
"""

import requests
import json

BASE_URL = "http://localhost:8000"

def test_health():
    """Test health endpoint"""
    response = requests.get(f"{BASE_URL}/health")
    print(f"Health check: {response.status_code}")
    print(f"Response: {response.json()}")
    return response.status_code == 200

def test_koan_generation():
    """Test koan generation"""
    test_cases = [
        {
            "user_text": "我总是想要得到更多，心里很不安",
            "hints": ["seeking"]
        },
        {
            "user_text": "看到美丽的花朵，心里很执着",
            "hints": ["clinging_form"]
        },
        {
            "user_text": "思绪很乱，无法专注",
            "hints": ["scattered"]
        },
        {
            "user_text": "感觉一切都是空的",
            "hints": ["emptiness_fixation"]
        },
        {
            "user_text": "我觉得自己很重要",
            "hints": ["ego_focus"]
        }
    ]
    
    for i, test_case in enumerate(test_cases):
        print(f"\n--- Test Case {i+1} ---")
        print(f"Input: {test_case['user_text']}")
        print(f"Hints: {test_case['hints']}")
        
        response = requests.post(
            f"{BASE_URL}/koan/generate",
            json=test_case,
            headers={"Content-Type": "application/json"}
        )
        
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print(f"Mirror: {result['mirror']}")
            print(f"Koan: {result['koan']}")
            print(f"Practice: {result['micro_practice']}")
            if result.get('quote'):
                print(f"Quote: {result['quote']}")
            print(f"Policy: {result['policy_note']}")
        else:
            print(f"Error: {response.text}")

def test_crisis_detection():
    """Test crisis keyword detection"""
    print("\n--- Crisis Detection Test ---")
    
    crisis_text = "我感到绝望，觉得活着没有意义"
    response = requests.post(
        f"{BASE_URL}/koan/generate",
        json={"user_text": crisis_text},
        headers={"Content-Type": "application/json"}
    )
    
    print(f"Crisis input: {crisis_text}")
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        result = response.json()
        print(f"Response: {result}")
        # Should not contain koan for crisis cases
        assert result['koan'] == "", "Crisis response should not contain koan"
        print("✓ Crisis detection working correctly")

def test_rate_limiting():
    """Test rate limiting"""
    print("\n--- Rate Limiting Test ---")
    
    # Send many requests quickly
    for i in range(65):  # Exceed the 60/min limit
        response = requests.post(
            f"{BASE_URL}/koan/generate",
            json={"user_text": f"test {i}"},
            headers={"Content-Type": "application/json"}
        )
        
        if response.status_code == 429:
            print(f"✓ Rate limiting triggered at request {i+1}")
            break
    else:
        print("⚠ Rate limiting may not be working")

if __name__ == "__main__":
    print("Testing Koan Orchestrator API...")
    
    if test_health():
        print("✓ Health check passed")
        test_koan_generation()
        test_crisis_detection()
        test_rate_limiting()
    else:
        print("✗ Health check failed - is the server running?")
        print("Start server with: python main.py")