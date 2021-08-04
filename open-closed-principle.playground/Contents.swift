
/*
 Design Patterns in Swift
 
    - Open-closed Principle with the Specification Design Pattern
 
*/

import Foundation

enum Color {
    case red
    case green
    case blue
}

enum Size {
    case small
    case medium
    case large
    case huge
}

class Product {
    var name: String
    var color: Color
    var size: Size
    
    init(_ name: String, _ color: Color, _ size: Size) {
        self.name = name
        self.color = color
        self.size = size
    }
}

//MARK: - Bad Code, NOT open-closed compliant

// Every time we are asked to create an extension of the functionalities we have
// to add a function to the Class that we've already implemented and the code is
// almost identical for all the functions
// BAD
class ProductFilter {
    func filterByColor (_ products: [Product], _ color: Color) -> [Product] {
        var result = [Product]()
        
        for item in products {
            if item.color == color {
                result.append(item)
            }
        }
        
        return result
    }
    
    func filterBySize (_ products: [Product], _ size: Size) -> [Product] {
        var result = [Product]()
        
        for item in products {
            if item.size == size {
                result.append(item)
            }
        }
        
        return result
    }
    
    func filterBySizeAndColor (_ products: [Product], _ size: Size, _ color: Color) -> [Product] {
        var result = [Product]()
        
        for item in products {
            if item.size == size && item.color == color {
                result.append(item)
            }
        }
        
        return result
    }
}

//MARK: - BETTER Code: Open-closed compliant
    
// Classes should be open for extension and closed to modification: we can extend
// a class (eg through inheritance) without modifying its fundamental structure.
// This is the open-closed principle.
// We can implement a better and more flexible filter class by adding a couple of
// protocols for specifying things like specifications and filtering etc...
// The open-closed principle is uned in the Specification Design Pattern.

// Specification protocol: checks whether an item satisfies some criteria
protocol Specification {
    associatedtype T
    
    func isSatisfied(_ item: T) -> Bool
}

// Very general definition for filter
protocol Filter {
    associatedtype T
    func filter<Spec: Specification>(_ items: [T], _ spec: Spec) -> [T] where Spec.T == T
}

class ColorSpecification: Specification {
    typealias T = Product
    
    let color: Color
    init(_ color: Color) {
        self.color = color
    }
        
    func isSatisfied(_ item: Product) -> Bool {
        return item.color == color
    }
}

class SizeSpecification: Specification {
    typealias T = Product
    
    let size: Size
    init(_ size: Size) {
        self.size = size
    }
    
    func isSatisfied(_ item: Product) -> Bool {
        return item.size == size
    }
    
}

// Instead of creating a SizeAndColor SPecification we are going to create
// an AND Specification which is more generic and flexible.
class AndSpecification<T,
                       SpecA: Specification,
                       SpecB: Specification>: Specification
                       where SpecA.T == SpecB.T,
                       T == SpecA.T {
    let first: SpecA
    let second: SpecB
    
    init(_ first: SpecA, _ second: SpecB) {
        self.first = first
        self.second = second
    }
    
    func isSatisfied(_ item: T) -> Bool {
        return first.isSatisfied(item) && second.isSatisfied(item)
    }
}

class BetterFilter: Filter {
    typealias T = Product
    
    func filter<Spec>(_ items: [Product], _ spec: Spec) -> [Product] where Spec : Specification, Product == Spec.T {
        var result = [Product]()
        
        for item in items {
            if spec.isSatisfied(item) {
                result.append(item)
            }
        }
        return result
    }
}

//MARK: - MAIN Function

func main() {
    let apple = Product("apple", .red, .small)
    let watermelon = Product("watermelon", .green, .medium)
    let car = Product("ferrari", .red, .large)
    let iris = Product("iris", .blue, .small)
    
    let products = [apple, watermelon, car, iris]
    
    print("\n\nResult of Bad Code: Not open-closed compliant:\n")
    
    let pf = ProductFilter()
    
    let redItems = pf.filterByColor(products, .red)
    for item in redItems {
        print("Red item: \(item.name)")
    }
    
    let smallItems = pf.filterBySize(products, .small)
    
    for item in smallItems {
        print("Small item: \(item.name)")
    }
    
    let smallRedItems = pf.filterBySizeAndColor(products, .small, .red)
    for item in smallRedItems {
        print("Small and Red item: \(item.name)")
    }
    
    // Better Code here
    print("\n\nResult of Better Code: open-closed compliant\n")
    
    let bf = BetterFilter()
    
    let betterRedItems = bf.filter(products, ColorSpecification(.red))
    for item in betterRedItems {
        print("Better Red Items: \(item.name)")
    }
    
    let betterSmallItems = bf.filter(products, SizeSpecification(.small))
    for item in betterSmallItems {
        print("Better Small Items: \(item.name)")
    }
    
    let betterSmallAndRedItems = bf.filter(products, AndSpecification(SizeSpecification(.small), ColorSpecification(.red)))
    for item in betterSmallAndRedItems {
        print("Better Small and Red Items: \(item.name)")
    }
}

main()
