# Dolos 多洛斯

多洛斯在古希臘神話裡面代表著弄虛作假，欺騙手段，姦詐，背信棄義和詭計的神，也是此專案命名的由來。

## 此專案可以幹嘛?

- [x]  替換 File 上方描敘檔的創建日期跟創建者
- [x]  產生 Objective-C Spam Code
- [x]  產生 Swift Spam Code
- [x]  修改圖片名稱
- [x]  刪除 File 上方描敘檔
- [ ]  支援忽略路徑
- [x]  活躍的社群
- [ ]  更改檔案名稱

## 使用前先安裝





## 參數說明


|  參數名 |   解釋  |  備註 |
|---|---|---|
|   -spamCode   |   產生垃圾 code     | |
|   -handleXcassets    |   修改圖片名稱    |  |
|   -replaceFileDescription    |   替換 File 上方描敘檔的創建日期跟創建者   |  不可跟-deleteComments 同時使用 |
|    -deleteComments   |    刪除 File 上方描敘檔  | 不可跟-replaceFileDescription 同時使用 |
|    -ignoreDirNames(敬請期待)   |    被忽略的路徑  | 是用,分開 ex: Dir1,Dir2 |
|    -modifyProjectName(敬請期待)   |    修改專案名稱  |  |
|    -imageCompression(敬請期待)   |    圖片壓縮  |  |
|    -modifyFunctionName(敬請期待)   |    修正方法名稱  |  |


## 使用教學

### 一鍵使用

```sh
./Dolos /Path/MyProject -spamCode -handleXcassets -replaceFileDescription
```

## 使用教學詳細解說
```sh 
./Dolos <路徑> [-spamCode] [-handleXcassets]  [-replaceFileDescription|-deleteComments] [-ignoreDirNames [Dir1,Dir2]]
```

### **假設** 只需要  spamCode
```sh 
./Dolos /Path/MyProject -spamCode
```

### **假設** 只需要  spamCode 跟 修改圖片
```sh 
./Dolos /Path/MyProject -spamCode -handleXcassets
```

### **假設** 只需要  spamCode, 修改圖片, 修改檔案描敘
```sh 
./Dolos /Path/MyProject -spamCode -handleXcassets -replaceFileDescription
```

### **假設** 只需要  spamCode, 修改圖片, 刪除檔案描敘
```sh 
./Dolos /Path/MyProject -spamCode -handleXcassets -deleteComments
```






