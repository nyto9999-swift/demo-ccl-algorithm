import UIKit
class Block {
    var matrix = [[Int]]()
    var maxRow = 0, maxCol = 0
    var tag = 1
    var equivalencyList = [Int: Int]()
    var numberCount = [Int:Int]()
    var maxBlocks = [Int]()
    
    init () {
        let matrix = [
            [0,0,0,0,0,0,0,0,0,0],
            [0,1,1,1,0,0,0,0,0,0],
            [0,1,1,1,0,0,0,0,0,0],
            [0,1,1,1,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0,0],
            [0,0,0,0,1,0,0,1,1,0],
            [0,0,0,0,1,0,0,1,1,0],
            [0,0,0,0,1,1,1,1,1,0],
            [0,1,1,1,1,1,1,1,1,0],
            [0,1,1,1,1,1,1,1,1,0],
        ]
        
        self.maxRow = matrix.count
        self.maxCol = matrix[0].count
        self.matrix = matrix
        self.preparingInit()
    }
    
    func preparingInit() {
        for row in 0..<maxRow {
            for col in 0..<maxCol {
                if matrix[row][col] == 1 {
                    matrix[row][col] = -1
                }
            }
        }
    }
    
    func firstRasterScanForLabeling() {
        for row in 0..<maxRow {
            for col in 0..<maxCol {
                
                if matrix[row][col] == -1 {
                    //上 跟 左 沒有 label
                    if (matrix.safe[row - 1]?.safe[col] == 0 ||
                        matrix.safe[row - 1]?.safe[col] == nil) &&
                       (matrix.safe[row]?.safe[col - 1] == 0 ||
                        matrix.safe[row]?.safe[col - 1] == nil)
                    {
                        matrix[row][col] = tag
                        equivalencyList[tag] = tag
                        tag += 1
                    }
                    
                    //上跟左 同時有tag
                    else if (matrix.safe[row - 1]?.safe[col] != nil &&
                             matrix.safe[row - 1]?.safe[col] != 0) &&
                            (matrix.safe[row]?.safe[col - 1] != nil &&
                             matrix.safe[row]?.safe[col - 1] != 0)
                    {
                        // 上跟左的tag 一樣
                        if matrix.safe[row - 1]?.safe[col] == matrix.safe[row]?.safe[col - 1]
                        {
                            matrix[row][col] = matrix[row - 1][col]
                        }
                        // 上跟左的tag不一樣
                        else
                        {
                            let tag = matrix[row - 1][col] < matrix[row][col - 1]
                            ? matrix[row - 1][col] : matrix[row][col - 1]
                            
                            let key = matrix[row - 1][col] < matrix[row][col - 1]
                            ? matrix[row][col - 1] : matrix[row - 1][col]
                            
                            equivalencyList[key] = tag
                            matrix[row][col] = tag
                        }
                    }
                    
                    // 只有上有label
                    else if (matrix.safe[row - 1]?.safe[col] != 0 &&
                             matrix.safe[row - 1]?.safe[col] != nil)
                    {
                        matrix[row][col] = matrix[row - 1][col]
                    }
                    
                    // 只有左有label
                    else if (matrix.safe[row]?.safe[col - 1] != 0 &&
                             matrix.safe[row]?.safe[col - 1] != nil)
                    {
                        matrix[row][col] = matrix[row][col - 1]
                    }
                }
            }
        }
    }
    
    func SecondRasterScanForApplyEquivalences() {
        for row in 0..<maxRow {
            for col in 0..<maxCol {
                let equalValue = equivalencyList[matrix[row][col]]
                if matrix[row][col] != equalValue &&
                    equalValue != nil
                {
                    matrix[row][col] = equalValue!
                }
            }
        }
    }
    
    func countAndFindMaxBlockNumber() {
        self.removeDuplicatesForNumberCountDictionary()
        
        for numberDic in numberCount {
            var count = 0
            for row in 0..<maxRow {
                for col in 0..<maxCol {
                    if matrix[row][col] == numberDic.key {
                        count += 1
                        numberCount[numberDic.key] = count
                    }
                }
            }
        }
        
        let maxVal = numberCount.values.max() ?? 0
        let maxDic = numberCount.filter { $0.value == maxVal }
        maxBlocks = Array(maxDic.keys)
    }
    
    func removeDuplicatesForNumberCountDictionary() {
        var arr = [Int]()
        
        for value in equivalencyList.values {
            arr.append(value)
        }
        let nonDuplicatesNumbers = arr.removingDuplicates()
        for number in nonDuplicatesNumbers {
            numberCount[number] = 0
        }
    }
    
    func drawMaxBlock() {
        
        //刪除比最大區塊小的區塊
        for row in 0..<maxRow {
            for col in 0..<maxCol {
                if matrix[row][col] != maxBlocks[0] {
                    matrix[row][col] = 0
                }
            }
        }
        
        //顯示最大區塊
        for row in 0..<maxRow {
            for col in 0..<maxCol {
                if matrix[row][col] == maxBlocks[0] {
                    matrix[row][col] = 1
                }
            }
        }
        self.drawMatrix()
    }
    func drawMatrix() {
        for pixelsArray in matrix {
            print(pixelsArray)
        }
    }
}


var block = Block()
block.firstRasterScanForLabeling()
block.SecondRasterScanForApplyEquivalences()
block.countAndFindMaxBlockNumber()
block.drawMaxBlock()


// prevent running out of index
public struct SafeCollectionable<Base> where Base: Collection {
    
    let base: Base
    init(_ base: Base) {
        self.base = base
    }
    
    public subscript(_ index: Base.Index) -> Base.Element? {
        if !base.indices.contains(index) {
            return nil
        }
        return base[index]
    }
}
public extension Collection {
    var safe: SafeCollectionable<Self> {
        return SafeCollectionable(self)
    }
}

// 其除array的重複元素
extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
