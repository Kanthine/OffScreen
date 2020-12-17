# iOS 渲染机制初窥

![渲染机制相关知识点](https://upload-images.jianshu.io/upload_images/7112462-71329fcd87fe7553.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


#### 1、渲染与成像

##### 1.1、`CPU` 与 `GPU` 处理器

对于现代计算机系统，简单来说可以大概视作三层架构：硬件、操作系统与进程。对于移动端来说，进程就是 App，而 CPU 与 GPU 是硬件层面的重要组成部分。CPU 与 GPU 提供了计算能力，通过操作系统被 App 调用。


区别|CPU `Central Processing Unit` |GPU `Graphics Processing Unit`
-|-|-
名称|中央处理器，系统的运算核心、控制核心 |  图形处理器
工作范围|大都在软件层面，适用于串行计算|大都在硬件层面，适用于并行计算
设计目的|低时延，更多的高速缓存，更快速地处理逻辑分支|更强的计算能力，基于大吞吐量而设计
工作场景|需要很强的通用性来处理各种不同的类型数据，同时又要逻辑判断又会引入大量的分支跳转和中断处理 | 面对类型高度统一的、相互无依赖的大规模数据和不需要被打断纯净的计算环境
架构|CPU的内部结构异常复杂，拥有更多的缓存空间以及复杂的控制单元 | GPU 基于大吞吐量而设计，拥有更多的计算单元 `Arithmetic Logic Unit`

![CPU与GPU](https://upload-images.jianshu.io/upload_images/7112462-a43a7562c29fb9b2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


GPU 优秀的并行计算能力使其能够快速将图形结果计算出来并在屏幕的所有像素中进行显示。

##### 1.2、`CPU+GPU` 渲染流水线

图像渲染流程粗粒度地大概分为下面这些步骤：

![图像渲染流水线](https://upload-images.jianshu.io/upload_images/7112462-748b7eaa6a870b87.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


除了第一阶段 Application 由`CPU`负责，后续主要都由 `GPU` 负责：

![GPU负责的一个三角形渲染流程](https://upload-images.jianshu.io/upload_images/7112462-cad7d01d3dc2824f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


一个简单的三角形绘制就需要大量的 `GPU` 资源来计算；针对更多更复杂的顶点、颜色、纹理信息，其计算量是难以想象的。这也是为什么 GPU 更适合于渲染。

详细分析渲染流水线中各个阶段的具体任务：

###### Ⅰ、Application 应用处理阶段：得到图元

该阶段具体指的是图像在 App 中被处理的阶段，此时还处于 CPU 负责的时期。
在该阶段 App 会对图像进行一系列的操作或者改变，最终将新的图像信息传给下一阶段。
这部分信息被叫做图元，通常是三角形、线段、顶点等。


###### Ⅱ、Geometry 几何处理阶段：处理图元


这个阶段以及之后的阶段，主要由 GPU 负责。
此时 GPU 可以拿到 `Application` 阶段传递下来的图元信息、并对这部分图元进行处理，然后输出新的图元。
这一系列阶段包括：
* 顶点着色器 `Vertex Shader`：将图元中的顶点信息进行视角转换、添加光照信息、增加纹理等操作；
* 形状装配 `Shape Assembly`：图元中的三角形、线段、点分别对应三个顶点、两个顶点、一个顶点；这个阶段会将`顶点`连接成相应的形状；
* 几何着色器`Geometry Shader`：添加额外的顶点，将原始图元转换成新图元，以构建一个不一样的模型。简单来说就是基于三角形、线段和点构建更复杂的几何图形。

###### Ⅲ、Rasterization 光栅化阶段：图元转换为像素

光栅化的主要目的是将几何渲染之后的图元信息，转换为一系列的像素，以便后续显示在屏幕上。
这个阶段中会根据图元信息，计算出每个图元所覆盖的像素信息等，从而将像素划分成不同的部分。

![光栅化](https://upload-images.jianshu.io/upload_images/7112462-fe7aed6152423776.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


一种简单的划分就是根据中心点：__如果像素的中心点在图元内部，那么这个像素就属于这个图元__。如上图所示，深蓝色的线就是图元信息所构建出的三角形；而通过是否覆盖中心点，可以遍历出所有属于该图元的所有像素，即浅蓝色部分。


###### Ⅳ、Pixel 像素处理阶段：处理像素，得到位图

经过光栅化阶段，可以得到图元所对应的像素；此时，需要给这些像素填充颜色和效果。所以最后这个阶段就是给像素填充正确的内容，最终显示在屏幕上。
这些经过处理、蕴含大量信息的像素点集合，被称作 __位图 `bitmap`__ 。也就是说，Pixel 阶段最终输出的结果就是位图，过程具体包含：


* 片段着色器`Fragment Shader`：也叫做 `Pixel Shader`，这个阶段的目的是给每一个像素 Pixel 赋予正确的颜色。颜色的来源就是之前得到的顶点、纹理、光照等信息。由于需要处理纹理、光照等复杂信息，所以这通常是 _整个系统的性能瓶颈_。
* 测试与混合`Tests and Blending`：也叫做 `Merging 阶段` ，这个阶段主要处理片段的前后位置以及透明度。这个阶段会检测各个着色片段的深度值 `z` 坐标，从而判断片段的前后位置，以及是否应该被舍弃。同时也会计算相应的透明度 `alpha` 值，从而进行片段的混合，得到最终的颜色。


这些点可以进行不同的排列和染色以构成图样。当放大位图时，可以看见赖以构成整个图像的无数单个方块。只要有足够多的不同色彩的像素，就可以制作出色彩丰富的图象，逼真地表现自然界的景象。缩放和旋转容易失真，同时文件容量较大。


##### 1.3、屏幕成像

在图像渲染流程结束之后，接下来就需要将得到的 `bitmap` 信息显示在物理屏幕上了。

CPU 计算好显示内容提交至 GPU，GPU 渲染结束后将 `bitmap` 信息缓存在 __帧缓冲区 `Framebuffer`__ 中； __显示控制器 `VideoController`__ 收到 `VSync` 信号后逐帧读取 `Framebuffer` 中的数据，经过 _数模转换_ 传递给 __显示器`Monitor`__ 进行显示。完整的流程如下图所示：

![常见的 CPU、GPU、显示器工作方式](https://upload-images.jianshu.io/upload_images/7112462-f5debf28b322ce1f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


##### 1.4、显示器原理

> 显示器的电子束从上到下逐行扫描，扫描完成后显示器就呈现一帧画面；然后电子束回到初始位置进行下一次扫描。

为了同步显示器的显示过程和系统的显示控制器，显示器会用硬件时钟产生一系列的定时信号：
* 水平同步信号`horizonal synchronization`，简称 `HSync`：当电子束换行进行扫描时，显示器会发出一个`HSync`信号；
* 垂直同步信号`vertical synchronization`，简称`VSync`： 当一帧画面绘制完成后，电子束回复到原位，准备画下一帧前，显示器会发出一个 `VSync` 信号；

![电子束扫描](https://upload-images.jianshu.io/upload_images/7112462-8902ca4c6d3a37d8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


电子束扫描的过程中，屏幕就能呈现出对应的结果，每次整个屏幕被电子束扫描完一次后，就相当于呈现了一帧完整的图像。屏幕不断地刷新，不停呈现新的帧，就能呈现出连续的影像。而这个屏幕刷新的频率，就是 __帧率__（Frame per Second，FPS）。由于人眼的视觉暂留效应，当屏幕刷新频率足够高时（FPS 通常是 50 到 60 左右），就能让画面看起来是连续而流畅的。_对于 iOS 而言，App 应该尽量保证 60 FPS 才是最好的体验_。

##### 1.5、屏幕撕裂 Screen Tearing

> CPU+GPU 的渲染流程是一个非常耗时的过程。

在单一缓存的模式下，理想情况是：每次电子束从头开始新的一帧的扫描时，CPU+GPU 对于该帧的渲染流程已经结束，渲染好的 `bitmap` 已经放入`Framebuffer`中。但这种完美的情况是非常脆弱的，很容易产生屏幕撕裂：

![屏幕撕裂](https://upload-images.jianshu.io/upload_images/7112462-2224adb1148a3144.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


如果在电子束开始扫描新的一帧时，`bitmap` 还没有渲染好，而是在扫描到屏幕中间时才渲染完成，被放入`Framebuffer`中； 那么已扫描的部分就是上一帧的画面，而未扫描的部分则会显示新的一帧图像，这就造成 __屏幕撕裂__ 。

##### 1.6、垂直同步 `Vsync` + 双缓冲机制 `Double Buffering`

> iOS 设备会始终使用 `Vsync + Double Buffering` 的策略。

解决屏幕撕裂、提高显示效率的一个策略就是使用垂直同步信号 `Vsync` 与双缓冲机制 `Double Buffering`。

使用 `Vsync`信号给 `Framebuffer` 加锁：只有当显示控制器接收到 `Vsync`信号时，才会将`Framebuffer`中的`bitmap`更新为下一帧，这样就能保证每次显示的都是同一帧的画面，也就避免了屏幕撕裂。

这种情况下要求显示控制器在接受到 `Vsync` 信号后将下一帧的`bitmap`传入；这意味着整个  CPU+GPU 的渲染流程都要在一瞬间完成，这明显是不现实的。

使用 __双缓冲机制__ 会增加一个新的 _备用缓冲区_ `BackBuffer`：渲染结果会预先保存在 `BackBuffer` 中；在接收到 `Vsync` 信号的时候，显示控制器会将 `BackBuffer` 中的内容置换到  `Framebuffer`  中，此时就能保证置换操作几乎在一瞬间完成（实际上是交换了内存地址）。

![双缓冲](https://upload-images.jianshu.io/upload_images/7112462-33bb699421bd12e7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


##### 1.7、屏幕卡顿的本质：掉帧 Jank

> 屏幕刷新频率必须要足够高才能流畅


使用  `Vsync` 信号以及双缓冲机制之后，能够解决屏幕撕裂的问题，但是会引入新的问题：掉帧。
如果在接收到  `Vsync` 之时 CPU 和 GPU 还没有渲染好新的位图，显示控制器就不会去替换`Framebuffer`  中的`bitmap`；这时屏幕就会重新扫描呈现出上一帧的画面；两个周期显示同一 `bitmap`，这就是所谓 __掉帧__ 的情况。

![掉帧](https://upload-images.jianshu.io/upload_images/7112462-693e98154ec1bc41.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


如图所示，A、B 代表两个`Framebuffer`，当 B 没有渲染完毕时就接收到了 `Vsync` 信号，所以屏幕只能再显示相同帧 A，这就发生了第一次的掉帧。


App 卡顿的直接原因：__CPU 和 GPU 渲染流水线耗时过长，导致掉帧__ 。对于 iPhone 手机来说，屏幕最大的刷新频率是 60 FPS，一般只要保证 50 FPS 就已经是较好的体验了。__如果掉帧过多，导致刷新频率过低，就会造成不流畅的使用体验__。


##### 1.8、三缓冲 Triple Buffering

在上述策略中发生掉帧的时候，CPU 和 GPU 有一段时间处于闲置状态：当 A 的内容正在被扫描显示在屏幕上，而 B 的内容已经被渲染好，此时 CPU 和 GPU 就处于闲置状态。
如果再增加一个帧缓冲区，就可以利用这段时间进行下一步的渲染，并将渲染结果暂存于新增的帧缓冲区。

![三缓冲](https://upload-images.jianshu.io/upload_images/7112462-daf73e687a662d52.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


如图所示，由于增加了新的帧缓冲区，可以一定程度上地利用掉帧的空档期，合理利用 CPU 和 GPU 性能，从而减少掉帧的次数。

在Android4.1系统开始，引入了三缓冲+垂直同步的机制。由于多加了一个 Buffer，实现了 CPU 跟 GPU 并行，便可以做到了只在开始掉一帧，后续却不掉帧。


缓冲机制|意义 
-|-
Vsync 与双缓冲|强制同步屏幕刷新，以掉帧为代价解决屏幕撕裂问题
三缓冲|合理使用 CPU、GPU 渲染性能，减少掉帧次数



#### 2、 iOS 的渲染

了解了计算机的大致渲染流程后，我们回到主题，iOS App 的渲染大致是一个怎样的过程呢？

##### 2.1、iOS  的渲染框架

iOS App 的图形渲染依然符合渲染流水线的基本架构；在硬件基础之上，使用了 `CoreGraphics`、`CoreAnimation`、`CoreImage` 等框架来绘制可视化内容，这些软件框架相互之间也有着依赖关系；但都需要通过 `OpenGL` 来调用 GPU 进行绘制，最终将内容显示到屏幕之上。


![iOS渲染框架](https://upload-images.jianshu.io/upload_images/7112462-90a5841fcf762bc9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


* `UIKit` ：是 iOS 开发者最常用的框架，通过设置 `UIKit` 组件的布局以及相关属性来绘制界面。
事实上， `UIKit` 并不具备在屏幕成像的能力，其主要负责对用户操作事件的响应（`UIView` 继承自 `UIResponder`），事件响应的传递大体是经过 _视图树_ 逐层的遍历实现的。

* `GPU Driver`：软件框架最终通过 `OpenGL` 连接到 `GPU Driver`，`GPU Driver` 是直接和 GPU 交流的代码块，直接与 GPU 连接。

* `OpenGL`：是一个提供了 2D 和 3D 图形渲染的 API，它能和 GPU 密切的配合，高效利用 GPU 能力实现硬件加速渲染。`OpenGL`的高效实现（利用了图形加速硬件）一般由显示设备厂商提供，而且非常依赖于该厂商提供的硬件。`OpenGL` 之上扩展出很多东西，如 `CoreGraphics` 等最终都依赖于 `OpenGL`，有些情况下为了更高的效率，比如游戏程序，甚至会直接调用 `OpenGL` 的接口。

* `Metal` 类似于 `OpenGL`，也是一套第三方标准，具体实现由苹果实现。大多数开发者仅仅间接的使用 `Metal`。`CoreAnimation`、`CoreImage`、`SceneKit`、`SpriteKit` 等等渲染框架都是构建于 `Metal` 之上的。

* `CoreAnimation`：源自于 `LayerKit`，是一个复合引擎，主要职责包含：渲染、构建和实现动画；可视内容可被分解成独立的图层`CALayer`，这些图层会被存储在一个叫做 __图层树__ 的体系之中，这个树是 iOS 应用程序中所能在屏幕上看见的一切的基础。
`CoreAnimation` 是 `AppKit` 和 `UIKit` 完美的底层支持，是 App 界面渲染和构建的最基础架构。

* `CoreGraphics`：基于 `Quartz` 高级绘图引擎，主要用于 _运行时绘制图像_，在运行时实时计算、绘制一系列图像帧来实现动画 ；是一个强大的二维图像绘制引擎，用来处理基于路径的绘图，转换，颜色管理，离屏渲染，图案，渐变和阴影，图像数据管理，图像创建和图像遮罩以及 PDF 文档创建，显示和分析。常用的 `CGRect` 就定义在这个框架下。

* `CoreImage`： 一个高性能的图像处理分析的框架，它拥有一系列现成的图像滤镜，能对  _已存在的图像_ 进行高效的处理。


###### `CoreAnimation` 动画

`CoreAnimation` 动画是基于事务的动画，是最常见的动画实现方式。动画执行者是专门负责渲染的渲染进程 `Render Server`，操作的是呈现树。
开发者应该尽量使用 `CoreAnimation` 来控制动画，因为 `CoreAnimation` 是充分优化过的；基于`Layer`的绘图过程中，`CoreAnimation` 通过硬件操作位图（变换、组合等），产生动画的速度比软件操作的方式快很多。

基于 `View` 的绘图过程中，`view` 被改动时会触发的 `-drawRect:` 方法来重新绘制位图，但是这种方式需要 CPU 在主线程执行，比较耗时。而 `CoreAnimation` 则尽可能的操作硬件中已缓存的位图，来实现相同的效果，从而减少了资源损耗。


###### 非`CoreAnimation` 动画

非 `CoreAnimation` 动画执行者是当前进程，操作的是模型树；常见的有定时器动画和手势动画：
* 定时器动画是在定时周期触发时修改模型树的图层属性；
* 手势动画是手势事件触发时修改模型树的图层属性。
两者都能达到视图随着时间不断变化的效果，即实现了动画。

非 `CoreAnimation` 动画过程中实际上不断改动的是模型树，而呈现树仅仅成了模型树的复制品，状态与模型树保持一致。整个过程中，主要是CPU在主线程不断调整图层属性、布局计算、提交数据，没有充分利用到 `CoreAnimation` 强大的动画控制功能。



##### 2.2、iOS App 的渲染流水线

> App 本身并不负责渲染，渲染由一个独立的进程 `Render Server`负责。


App 使用 CPU 处理触摸事件、显示内容的前置计算；然后通过 _进程间通信_ 将渲染任务及相关数据提交给 `Render Server`；`Render Server` 处理完数据后，再传递至 GPU；最后由 GPU 调用 iOS 的图像设备进行显示。

![App的渲染流水线](https://upload-images.jianshu.io/upload_images/7112462-9a9612f016a3417b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

渲染流水线可以分为下述步骤：

*  App 处理 `Handle Events`事件，如用户的点击操作；在此过程中 App 可能需要更新 __视图树__ ，相应地 __图层树__ 也会被更新；
*  App 的 `Commit Transaction`：App 通过 CPU 处理显示内容的前置计算，如：视图创建、布局计算、图片解码、文本绘制等任务；之后将计算好的图层打包，并在下一次 `RunLoop` 时将其发送至 `Render Server`，即完成了一次 `Commit Transaction` 操作。
*  解码 `Decode`：打包好的图层被传输到 `Render Server` 之后，首先会进行解码。注意完成解码之后需要等待下一个 `RunLoop` 才会执行下一步 `Draw Calls`。
* `Draw Calls`：解码完成后，`CoreAnimation` 会调用下层渲染框架（比如 `OpenGL` 或者 `Metal`）的方法进行绘制，进而调用到 GPU。
* 渲染阶段 `Render`：这一阶段主要由 GPU 在物理层上完成了对图像的渲染。
* 显示阶段 `Display`：需要等 `render` 结束的下一个 `RunLoop` 触发显示。


###### 2.2.1、`Commit Transaction` 都做了那些工作？

一般而言，开发者能接触并影响到的就是 `Handle Events` 和 `Commit Transaction` 这两个阶段。
`Handle Events` 就是处理触摸事件，而 `Commit Transaction` 主要进行的是：`Layout`、`Display`、`Prepare`、`Commit` 等四个具体的操作。


###### Ⅰ、 `Layout`：构建视图

这个阶段主要处理视图的构建和布局，具体步骤包括：

* 调用重载的 `-layoutSubviews` 方法；
* 创建视图，并通过 `-addSubview:` 方法添加子视图；
* 计算视图布局，即所有的 `Layout Constraint`；

由于这个阶段是在 CPU 中进行，通常是 CPU 限制或者 IO 限制，所以应尽量高效、轻量地操作，减少这部分的时间，比如减少非必要的视图创建、简化布局计算、减少视图层级等。

###### Ⅱ、`Display`：绘制视图

这个阶段主要是交给 `CoreGraphics` 进行视图的绘制，得到 _图元_ 数据：

* 根据上一阶段 `Layout` 的结果创建得到图元信息；
* 如果重写了  `-drawRect:` 方法，那么会调用重载的 `-drawRect:` 方法，在该方法中手动绘制得到 `bitmap` 数据，从而自定义视图的绘制；

注意正常情况下 `Display` 阶段只会得到图元信息，而位图 `bitmap` 是在 GPU 中根据图元信息绘制得到的。但是如果重写了 `-drawRect:` 方法，这个方法会直接调用 `CoreGraphics` 绘制方法得到 `bitmap` 数据，同时系统会额外申请一块内存，用于暂存绘制好的 `bitmap`。

由于重写了  `-drawRect:` 方法，绘制过程从 GPU 转移到了 CPU，会导致一定的效率损失。与此同时，这个过程会额外使用 CPU 和内存，因此需要高效绘制，否则容易造成 CPU 卡顿或者内存爆炸。


###### Ⅲ、 `Prepare`：`CoreAnimation` 额外的工作

这一步主要是：图片解码和转换

###### Ⅳ、 `Commit`：打包并发送

这一步主要是：图层打包并发送到  `Render Server`。

注意  `Commit` 操作是依赖图层树递归执行的，所以如果图层树过于复杂，`Commit` 的开销就会很大。这也是开发者减少视图层级，从而降低图层树复杂度的原因。


##### 2.3、 视图`UIView` 与 图层`CALayer` 

###### 2.3.1、图层 `CALayer`  

> 图层 `CALayer`  是用户所能在屏幕上看见的一切的基础，用来存放 _位图_ `Bitmap` 。

`CALayer` 有这样一个属性 `contents`：保存了由设备渲染流水线渲染好的位图 `bitmap`（通常也被称为 backing store），而当设备屏幕进行刷新时，会从 `CALayer` 中读取生成好的 `bitmap`，进而呈现到屏幕上。

``` 
/** 该属性提供了图层 CALayer 的内容，是一个指针类型
 * 在 iOS 中的类型就是 CGImageRef ；在 OS X 10.6 及更高版本上还可以是 NSImage
 * 默认值为 nil
 * @note contents 属性赋予任何值，App 均可以编译通过；但如果 content 的值不是 CGImageRef ，得到的图层将是空白；
 * 本质上，contents 指向一块缓存区域，称为 backing store，可以存放 bitmap 数据
 **/
@property(nullable, strong) id contents;
```

图形渲染流水线支持从顶点开始进行绘制（在流水线中，顶点会被处理生成 _纹理_），也支持直接使用 _纹理（图片）_ 进行渲染。相应地，在实际开发中，绘制界面也有两种方式：一种是 _手动绘制_；另一种是 _使用图片_:
* 使用图片`contents image` ： 赋值 `CGImageRef` 类型的图片；
* 手动绘制：`custom drawing`：使用 `CoreGraphics` 直接绘制 _寄宿图_；实际开发中，一般通过继承 `UIView` 并实现 `-drawRect:` 方法来自定义绘制；

```
// 注意 CGImage 和 CGImageRef 的关系：
// typedef struct CGImage CGImageRef;
layer.contents = (__bridge id)image.CGImage;**
```

虽然 `-drawRect:` 是一个 `UIView` 方法，但事实上都是底层的 `CALayer` 完成了重绘工作并保存了产生的图片。下图所示为 `-drawRect:` 绘制定义寄宿图的基本原理

![`UIView` 与 `CALayer`](https://upload-images.jianshu.io/upload_images/7112462-3fa740201d9f21ae.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


* `UIView` 有一个关联图层，即 `CALayer`；
* `CALayer` 有一个可选的 `delegate` 属性，实现了 `CALayerDelegate` 协议。`UIView` 作为 `CALayer` 的代理实现了 `CALayerDelegae` 协议；
* 当需要重绘时，即调用 `-drawRect:`，`CALayer` 请求其代理给予一个寄宿图来显示；
* `CALayer` 首先会尝试调用 `-displayLayer:` 方法，此时代理可以直接设置 `contents` 属性。
* 如果代理没有实现 `-displayLayer:` 方法，`CALayer` 则会尝试调用 `-drawLayer:inContext:` 方法。在调用该方法前，`CALayer` 会创建一个空的寄宿图（尺寸由 `bounds` 和 `contentScale` 决定）和一个 `CoreGraphics` 的绘制上下文，为绘制寄宿图做准备，作为 `context` 参数传入。
* 最后，由 `CoreGraphics` 绘制生成的寄宿图会存入 backing store。


###### 2.3.2、视图 `UIView`

`UIView` 是 iOS App 中的基本组成结构，定义了一些统一的规范；它会负责内容的渲染、交互事件的处理。
* `Drawing and animation`：绘制与动画
* `Layout and subview management`：布局与子 view 的管理
* `Event handling`：点击事件处理


###### 2.3.3、 `UIView` 与 `CALayer` 的关系

`CALayer` 是 `UIView` 的属性之一，负责渲染和动画，提供可视内容的呈现。
`UIView`的职责是 __创建并管理__ `CALayer`，以确保当子视图在层级关系中 __添加或被移除__  时，其关联的图层在图层树中也有相同的操作，即保证视图树和图层树在结构上的 __一致性__ 。

* 相同的层级结构： `UIView` 层级拥有 __视图树__ 的树形结构，由于每个 `UIView` 都对应  CALayer  负责页面的绘制，所以 `CALayer` 也具有相应的 __图层树__ 的树形结构。
* 部分效果的设置： `UIView` 只对 `CALayer` 的部分功能进行了封装；而另一部分如圆角、阴影、边框等特效都需要通过调用 `CALayer` 属性来设置；
* 是否响应点击事件：`CALayer` 不负责点击事件，所以不响应点击事件，而 `UIView` 会响应；
* 不同继承关系：`CALayer` 继承自 `NSObject`，`UIView` 由于要负责交互事件，所以继承自 `UIResponder`；


###### 2.3.4、为什么 iOS 要基于 `UIView` 和 `CALayer` 提供两个平行的层级关系呢？

这样设计的主要原因就是为了 __职责分离__，拆分功能，方便代码的复用。

iOS 平台基于多点触控的用户界面 和 Mac OS X 平台基于鼠标键盘的交互有着本质的区别；这就是为什么 iOS 有 `UIKit` 和 `UIView`，对应 Mac OS X 有 `AppKit` 和 `NSView` 的原因；它们在功能上很相似，但是在实现上有着显著的区别。

通过 `CoreAnimation` 框架来负责可视内容的呈现，这样在 iOS 和 Mac OS X 上都可以使用  `CoreAnimation` 进行渲染。

#### 3、离屏渲染

##### 3.1、什么是离屏渲染？

正常的渲染流程如下图所示：

![正常渲染流程](https://upload-images.jianshu.io/upload_images/7112462-02c0dc5e52ef9315.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


App 通过 CPU 与 GPU 的合作，不停地将内容渲染完成放入 `Framebuffer` 中，而显示器不断地从 `Framebuffer` 中获取内容，显示实时的内容。如果有时因为面临一些限制，无法把渲染结果直接写入`Framebuffer`，而是先暂存在另外的内存区域，之后再写入`Framebuffer`，那么这个过程被称之为_离屏渲染_。

![离屏渲染流程](https://upload-images.jianshu.io/upload_images/7112462-fbcfaff19593195e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


_离屏渲染_需要先额外创建离屏渲染缓冲区 `OffScreen Buffer`，将提前渲染好的内容放入其中，等到合适的时机再将 `OffScreen Buffer` 中的内容进一步叠加、渲染，完成后将结果切换到 `Framebuffer` 中。

##### 3.2、 CPU _离屏渲染_？ 

>  通过CPU渲染就是俗称的 _软件渲染_，而真正的离屏渲染发生在 GPU。

如果在 `UIView` 中实现了 `-drawRect:` 方法，就算它的函数体内部实际没有代码，系统也会为这个`view`申请一块内存区域，等待`CoreGraphics`可能的绘画操作。

类似这种 _新开一块 `CGContext` 来画图_ 的操作，称之为 _CPU离屏渲染_（因为像素数据是暂时存入了`CGContext`，而不是存入`Framebuffer`）。进一步来说，其实所有CPU进行的光栅化操作如文字渲染、图片解码等，都无法直接绘制到由GPU掌管的`Framebuffer` ，只能暂时先放在另一块内存之中，说起来都属于 _离屏渲染_ 。

自然我们会认为，因为CPU不擅长做这件事，所以我们需要尽量避免它，就误以为这就是需要避免离屏渲染的原因。但是根据苹果工程师的说法，CPU渲染并非真正意义上的离屏渲染。另一个证据是，如果你的`view`实现了 `-drawRect:`，此时打开 Xcode 调试的 `Color Off-Screen Rendered` 开关，你会发现这片区域不会被标记为黄色，说明 Xcode 并不认为这属于离屏渲染。


##### 3.3、 GPU _离屏渲染_

>  画家算法：首先绘制距离较远的场景，然后用绘制距离较近的场景覆盖较远的部分！

通常对于每一层`layer`，`Render Server` 会遵循 _画家算法_，按次序输出到`Framebuffer`，后一层覆盖前一层，就能得到最终的显示结果。

![画家算法：把每一层依次输出到画布](https://upload-images.jianshu.io/upload_images/7112462-c767f9b816c2f95b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


然而有些场景并没有那么简单。作为 _画家_ 的GPU虽然可以一层一层往画布上进行输出，但是无法在某一层渲染完成之后，再回过头来 _擦除/改变_ 其中的某个部分——因为在这一层之前的若干层`layer`像素数据，已经在渲染中被永久覆盖了。这就意味着， __对于每一层layer，要么能找到一种通过单次遍历就能完成渲染的算法，要么就不得不另开一块内存，借助这个临时中转区域来完成一些更复杂的、多次的修改/剪裁操作__ 。


比如：`cornerRadius+clipsToBounds`！对于多层`layer`的绘制，上层的 `sublayer` 会覆盖下层的 `sublayer`，下层 `sublayer` 绘制完之后就可以抛弃了，从而节约空间提高效率；所有 `layer` 依次绘制完毕之后，整个绘制过程完成，就可以进行后续的呈现了。

![多图层的一次渲染](https://upload-images.jianshu.io/upload_images/7112462-3891d6ee2a8cf97e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


设置 `layer.masksToBounds=YES` 之后，要求它的所有子图层裁剪圆角；这就意味着所有的  `sublayer` 在第一次被绘制完之后，并不能立刻被丢弃，而必须要被保存在 `OffScreen buffer` 中等待下一轮圆角裁剪，这也就诱发了离屏渲染，具体过程如下：

![多图层的多次渲染](https://upload-images.jianshu.io/upload_images/7112462-c7c892083fe80b40.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



###### 3.3.1、GPU 离屏渲染的效率问题

GPU的操作是高度流水线化的：本来所有计算工作都在有条不紊地正在向 `FrameBuffer` 输出，此时突然收到指令，需要输出到另一块内存 `OffScreen Buffer`，
* 那么流水线中正在进行的一切都不得不被丢弃，将某些渲染结果保存到 `OffScreen Buffer`；
* 等到完成以后再次清空，再回到向 `FrameBuffer`输出的正常流程；

上述两步关于 `buffer` 的切换代价都非常大：
*  `OffScreen Buffer` 本身就需要额外的空间，大量的离屏渲染可能早能内存的过大压力；
*  `OffScreen Buffer` 的总大小也有限，不能超过屏幕总像素的 2.5 倍；

可见离屏渲染的开销非常大，一旦需要离屏渲染的内容过多，很容易造成掉帧的问题。所以大部分情况下，我们都应该尽量避免离屏渲染。


__eg__：在 `UITableView` 或者 `UICollectionView` 中，滚动的每一帧变化都会触发每个 `cell` 的重新绘制，因此一旦存在离屏渲染，上面提到的上下文切换就会每秒发生 `60` 次，并且很可能每一帧有几十张的图片要求这么做，对于GPU的性能冲击可想而知（GPU非常擅长大规模并行计算，但频繁的上下文切换显然不在其设计考量之中）



###### 3.3.2、善用离屏渲染：光栅化

虽然离屏渲染开销很大，但如果无法避免它的时候，可以想办法把性能影响降到最低。优化思路也很简单：将花费大量资源裁出圆角的图片缓存下来，那么下一帧渲染就可以复用该缓存，不需要再重新画一遍了。

```
/** 表示是否开启光栅化
 * 开启光栅化后，会触发离屏渲染:
 *   Render Server 会强制将 CALayer 的渲染位图 bitmap 保存下来，这样下次再需要渲染时就可以直接复用，从而提高效率。
 *   保存的 bitmap 包含 layer 的 subLayer、圆角、阴影、组透明度等
 * 所以如果 layer 的构成包含上述几种元素，结构复杂且需要反复利用，那么就可以考虑打开光栅化。
 */
@property BOOL shouldRasterize;
```

开启光栅化的时候需要注意以下几点：

* 如果 `layer` 不能被复用，则没有必要打开光栅化；
* 如果 `layer` 不是静态，需要被频繁修改，比如处于动画之中，那么开启离屏渲染反而影响效率；
* 离屏渲染缓存内容有时间限制，缓存内容 `100ms` 内如果没有被使用，那么就会被丢弃，无法进行复用；
* 离屏渲染缓存空间有限，超过 2.5 倍屏幕像素大小的话也会失效，无法复用；


###### 3.3.3、iOS 开发中常见的离屏渲染

* `cornerRadius+clipsToBounds`：上文提过；

* 设置阴影 `shadow`：虽然 `layer` 本身是一块矩形区域，但是 `shadow` 默认是作用在其中 _非透明区域_ 的，而且需要显示在所有 `layer` 内容的下方，因此根据 _画家算法_ 必须被渲染在先。但矛盾在于此时 `shadow` 的本体 `layer` 都还没有被组合到一起，怎么可能在第一步就画出只有完成最后一步之后才能知道的形状呢？这样一来又只能另外申请一块内存，把本体内容都先画好，再根据渲染结果的形状，添加阴影到 `FrameBuffer`，最后把内容画上去。

![阴影作用在图层树所组成的形状上，只能等全部图层画完才能得到](https://upload-images.jianshu.io/upload_images/7112462-57ad1302fc1436d9.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


* 设置  `allowsGroupOpacity`：`opacity` 并不是分别应用在每一层 `layer` 之上，而是只有到整个 _图层树_ 画完之后，再统一加上`opacity`，最后和底下其他 `layer` 的像素进行组合；显然也无法通过一次遍历就得到最终结果。
将一对蓝色和红色 `layer` 叠在一起，然后在父 `layer`上设置 `opacity=0.5`，并复制一份在旁边作对比。左边关闭 `allowsGroupOpacity`，右边保持默认，然后打开 Xcode 调试的 `Color Off-Screen Rendered` 开关，会发现右边的那一组确实是离屏渲染了。
__注意__：从iOS7开始，如果没有显式指定，`allowsGroupOpacity`会默认为 `YES` ！

![设置groupOpacity](https://upload-images.jianshu.io/upload_images/7112462-2e5e09371259b0d2.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


* 设置蒙版 `mask`：`mask` 是应用在`layer`和其所有子`sublayer`的组合之上的，而且可能带有透明度；最终的内容是由 __多层渲染结果叠加__ ，所以必须要利用额外的内存空间对中间的渲染结果进行保存，因此系统会默认触发离屏渲染。

![WWDC中苹果的解释，mask需要遍历至少三次](https://upload-images.jianshu.io/upload_images/7112462-f1da7b3e7d1619d6.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


* 设置模糊特效 `UIBlurEffectView`：首先渲染需要模糊的内容本身；接着对内容进行缩放；然后分别对上一步内容进行横纵方向的模糊操作，最后一步用模糊后的结果叠加合成，最终实现完整的模糊特效。这也会触发离屏渲染。

![设置模糊特效](https://upload-images.jianshu.io/upload_images/7112462-83d0669c054a58e3.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


* 其他还有一些，类似绘制了文字的 `layer` (`UILabel`,`CATextLayer`,`CoreText` 等)。


__注意__ ： 重写 `-drawRect:` 方法触发 CPU 软件渲染，而非 GPU 离屏渲染。


###### 3.3.4、一些引发离屏渲染的优化

引起离屏渲染的本质是 __多层渲染结果叠加__，导致对 `layer` 以及所有 `sublayer` 进行多次处理。为避免对 `layer` 的多次处理，可以提前预处理，绘制时仅一次处理完成渲染。


* 对于图片的圆角：不经由容器来做剪切，而是预先使用 `CoreGraphics` 为图片裁剪圆角；
* 对于视频的圆角：由于实时剪切非常消耗性能，提前创建四个白色弧形的`layer`盖住四个角，从视觉上制造圆角的效果；
* 对于`view`的圆形边框：如果没有 `backgroundColor`，可以放心使用 `cornerRadius` 来做；
* 对于所有的阴影：使用 `shadowPath` 来规避离屏渲染；
* 对于特殊形状的`view`：使用 `layer.mask` 并打开 `shouldRasterize`来对渲染结果进行缓存；
* 对于模糊效果：不采用系统提供的 `UIVisualEffect`，而是另外实现模糊效果`CIGaussianBlur`，并手动管理渲染结果；



##### 3.4、什么时候需要 CPU 渲染？

> 渲染性能的调优，其实始终是在做一件事：平衡CPU和GPU的负载，让他们尽量做各自最擅长的工作。

![平衡CPU和GPU的负载 ](https://upload-images.jianshu.io/upload_images/7112462-89a87271f22b3e3f.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


一般情况下，得益于GPU针对图形处理的优化，我们都会倾向于让GPU来完成渲染任务，而给CPU留出足够时间处理各种各样复杂的App逻辑。为此 `Core Animation` 做了大量的工作，尽量把渲染工作转换成适合GPU处理的形式（也就是所谓的硬件加速，如 `layer composition`，设置 `backgroundColor`等等）。

但是对于一些情况，如文字（`CoreText`使用`CoreGraphics`渲染）和图片 `ImageIO` 渲染，由于GPU并不擅长做这些工作，不得不先由CPU来处理好以后，再把结果作为`texture`传给GPU。除此以外，有时候也会遇到GPU实在忙不过来的情况，而CPU相对空闲（GPU瓶颈），这时可以让CPU分担一部分工作，提高整体效率。

![CoreText基于CoreGraphics](https://upload-images.jianshu.io/upload_images/7112462-94a24493a303a697.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



这里有几个需要注意的点：

* 渲染不是CPU的强项，调用`CoreGraphics`会消耗其相当一部分计算时间，并且也不能因此阻塞用户操作，因此一般来说CPU渲染都在后台线程完成，然后再回到主线程上，把渲染结果传回 `CoreAnimation`。这样一来，多线程间数据同步会增加一定的复杂度 ；
* 同样因为CPU渲染速度不够快，因此只适合渲染静态的元素，如文字、图片；
* 作为渲染结果的`bitmap`数据量较大（形式上一般为解码后的`UIImage`），消耗内存较多，所以应该在使用完及时释放，并在需要的时候重新生成，否则很容易导致内存用完；
* 如果选择使用CPU来做渲染，那么就没有理由再触发GPU的离屏渲染了，否则会同时存在两块内容相同的内存，而且CPU和GPU都会比较辛苦；
* 一定要使用 `Instruments` 的不同工具来测试性能，而不是仅凭猜测来做决定；



----

参考文章

[iOS 渲染原理解析](https://blog.csdn.net/Desgard_Duan/article/details/106394306)
[关于iOS离屏渲染的深入研究](https://zhuanlan.zhihu.com/p/72653360)
[iOS下的图像渲染原理](https://juejin.cn/post/6847009772730843149)
