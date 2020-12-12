# MF-Metal-Example

## Introduction

### Initial goal

This project was originally inteded to explain two types of computation using the Metal framework from Apple.

- **Particles Calculator :** A simple computation optimized using the GPU power, using the Metal compute kernel. In this sample, we compute the force applied to _n_ particles by _m_ attractors. 
- **Gravity FIeld Calculator :** A Texture computation, where a metal language function is used to process a 2d texture that is displayed in a Metal view. In this sample, we compute the gravity force applied by to each pixel of the view by _m_ attractors. The result is a visual representation of the gravity fields.

The first example is a good base to compute anything using the Metal compute kernel, without any graphic consideration.

### Second goal

From there, since the result was quite amazing, I thought it would be a good idea to make a more solid app and propose an approach to architecture an app that use Metal framework.

So I propose a sketch of safe and scalable model to mix swift and metal data types.

### Last goal

- Make an app that runs on Mac and iPhone using as much common code as possible.
- Propose a mechanism that generates interface easily so anyone including me can have fun by adding new parameters seamlessly. It shows some usecases of generic constraints.

### Who's the public

This sample project is made for intermediate swift developper willing to have some insights the Metal basics. 

It is also a guideline on how to architecture swift software in a safe and scalable way.

I don't pretend to give the highest code quality or the best possible architecture, but simply to share my way to code after 30 years spent to scratch my head on these problems.

### References


[Metal Language Specification](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf)

[Metal Documentation](https://developer.apple.com/documentation/metal)

## <font color='#1E72AD'>Required frameworks</font>

Two frameworks are installed using cocoapods:
- **SnapKit :** A fantastic framework to handle constraints with no pain.
- **MoofFoundation :** Some of my most used code. A home made collection of utilities to extend Apple Foundation, Quartz, Metal, AppKit and Cocoa frameworks.

```
cd 'MF Metal Example'
pod install
```

### <font color='#1E72AD'>Mac OS Screenshot</font>

![MacDown logo](Documentation/ReadMeImage.jpg)

### <font color='#1E72AD'>iOS Screenshot</font>

![MacDown logo](Documentation/ReadMeImage-iOS.jpg)

## Overview

## <font color='#1E72AD'>Author</font>

Tristan Leblanc <tristan@moosefactory.eu>

Twitter     :    <https://www.twitter.com/tristanleblanc>  

***


## <font color='#1E72AD'>License</font>

MoofFoundation is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

***

Updated 2016-12-09
