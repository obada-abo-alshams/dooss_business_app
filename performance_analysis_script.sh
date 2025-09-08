#!/bin/bash

# Flutter Performance Analysis Script
# This script helps analyze and optimize Flutter app performance

echo "🚀 Flutter Performance Analysis Script"
echo "======================================"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"

# Function to analyze APK size
analyze_apk_size() {
    echo ""
    echo "📦 Analyzing APK Size..."
    echo "----------------------"
    
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        APK_SIZE=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
        echo "Release APK Size: $APK_SIZE"
        
        # Analyze APK contents
        echo "APK Contents Analysis:"
        flutter build apk --analyze-size --target-platform android-arm64
    else
        echo "⚠️ Release APK not found. Building release APK..."
        flutter build apk --release --target-platform android-arm64
        analyze_apk_size
    fi
}

# Function to analyze dependencies
analyze_dependencies() {
    echo ""
    echo "📚 Analyzing Dependencies..."
    echo "---------------------------"
    
    # Check for unused dependencies
    echo "Checking for unused dependencies:"
    flutter pub deps --json > deps.json
    
    # Count dependencies
    DIRECT_DEPS=$(grep -o '"direct"' pubspec.yaml | wc -l)
    echo "Direct dependencies: $DIRECT_DEPS"
    
    # Check for outdated packages
    echo "Checking for outdated packages:"
    flutter pub outdated
    
    rm -f deps.json
}

# Function to run performance tests
run_performance_tests() {
    echo ""
    echo "🏃‍♂️ Running Performance Tests..."
    echo "--------------------------------"
    
    # Run flutter analyze
    echo "Running flutter analyze..."
    flutter analyze
    
    # Check for performance issues
    echo "Checking for performance issues:"
    grep -r "setState" lib/ --include="*.dart" | wc -l | xargs echo "setState calls found:"
    grep -r "build(" lib/ --include="*.dart" | wc -l | xargs echo "build method calls found:"
    grep -r "ListView(" lib/ --include="*.dart" | wc -l | xargs echo "ListView instances found:"
}

# Function to analyze asset sizes
analyze_assets() {
    echo ""
    echo "🖼️ Analyzing Assets..."
    echo "--------------------"
    
    if [ -d "assets" ]; then
        echo "Asset directory sizes:"
        du -h assets/*/ 2>/dev/null || echo "No subdirectories in assets/"
        
        echo ""
        echo "Largest asset files:"
        find assets/ -type f -exec du -h {} + 2>/dev/null | sort -hr | head -10
        
        echo ""
        echo "Asset file types:"
        find assets/ -type f | sed 's/.*\.//' | sort | uniq -c | sort -nr
    else
        echo "⚠️ No assets directory found"
    fi
}

# Function to generate optimization recommendations
generate_recommendations() {
    echo ""
    echo "💡 Performance Optimization Recommendations"
    echo "==========================================="
    
    echo "1. Build Optimizations:"
    echo "   - Use 'flutter build apk --release --shrink' for smaller APKs"
    echo "   - Enable ProGuard/R8 obfuscation"
    echo "   - Use '--split-per-abi' to create architecture-specific APKs"
    
    echo ""
    echo "2. Code Optimizations:"
    echo "   - Use const constructors where possible"
    echo "   - Implement RepaintBoundary for complex widgets"
    echo "   - Use ListView.builder for large lists"
    echo "   - Implement lazy loading for heavy widgets"
    
    echo ""
    echo "3. Asset Optimizations:"
    echo "   - Compress images using tools like tinypng"
    echo "   - Use vector graphics (SVG) where possible"
    echo "   - Implement image caching"
    echo "   - Remove unused assets"
    
    echo ""
    echo "4. Network Optimizations:"
    echo "   - Implement request caching"
    echo "   - Use compression (gzip)"
    echo "   - Optimize API response sizes"
    echo "   - Implement connection pooling"
    
    echo ""
    echo "5. Memory Optimizations:"
    echo "   - Dispose controllers and streams properly"
    echo "   - Use weak references where appropriate"
    echo "   - Implement proper state management"
    echo "   - Monitor memory usage with Flutter Inspector"
}

# Function to create performance report
create_performance_report() {
    echo ""
    echo "📊 Creating Performance Report..."
    echo "-------------------------------"
    
    REPORT_FILE="performance_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "Flutter Performance Analysis Report"
        echo "Generated on: $(date)"
        echo "=================================="
        echo ""
        
        echo "Flutter Version:"
        flutter --version
        echo ""
        
        echo "Project Info:"
        echo "Name: $(grep '^name:' pubspec.yaml | cut -d' ' -f2)"
        echo "Version: $(grep '^version:' pubspec.yaml | cut -d' ' -f2)"
        echo ""
        
        if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
            echo "APK Size: $(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)"
        fi
        
        echo ""
        echo "Code Metrics:"
        find lib/ -name "*.dart" | wc -l | xargs echo "Dart files:"
        find lib/ -name "*.dart" -exec wc -l {} + | tail -1 | awk '{print $1}' | xargs echo "Total lines of code:"
        
        echo ""
        echo "Dependencies:"
        grep -c "^  [a-zA-Z]" pubspec.yaml | xargs echo "Direct dependencies:"
        
    } > "$REPORT_FILE"
    
    echo "✅ Performance report saved to: $REPORT_FILE"
}

# Main execution
main() {
    echo "Starting performance analysis..."
    
    # Check if we're in a Flutter project
    if [ ! -f "pubspec.yaml" ]; then
        echo "❌ This doesn't appear to be a Flutter project (no pubspec.yaml found)"
        exit 1
    fi
    
    analyze_dependencies
    analyze_assets
    run_performance_tests
    analyze_apk_size
    generate_recommendations
    create_performance_report
    
    echo ""
    echo "🎉 Performance analysis complete!"
    echo "Check the generated report for detailed insights."
}

# Run main function
main "$@"