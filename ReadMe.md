# Dart Object Pool / Dart 对象池

A lightweight **object pooling** implementation in Dart.  
这是一个轻量级的 **Dart 对象池实现**。

Object pools help reduce the overhead of frequent object creation and destruction by reusing objects efficiently.  
对象池通过高效地复用对象，减少频繁创建和销毁的开销。

---

## ✨ Features / 功能特性
- Generic object pool for any class that extends `PooledObject`.  
  为任意继承 `PooledObject` 的类提供通用对象池。
- Reuse existing objects instead of creating new ones.  
  重用已有对象，避免反复创建。
- Reduce GC (Garbage Collection) pressure in performance-sensitive scenarios.  
  在性能敏感场景下减少 GC 压力。
- Easy to extend for your custom classes.  
  易于扩展，适合自定义类。

---

## 🚀 Example Usage / 使用示例

```dart
class Bullet extends PooledObject {
  double x = 0;
  double y = 0;
  bool active = false;

  @override
  void initialize() {
    x = 0;
    y = 0;
    active = true;
  }

  @override
  void release() {
    active = false;
  }
}

void main() {

  // Acquire an object from the pool
  // 从对象池中获取对象
  Bullet bullet = PooledObject.createInstance<Bullet>();
  bullet.initialize();
  bullet.x = 100;
  bullet.y = 200;

  print("Bullet created at (${bullet.x}, ${bullet.y}), active: ${bullet.active}");

  // Release back to pool
  // 回收到对象池
  bullet.releaseToPool();
  print("Available bullets in pool: ${bullet.currentPool?.availableCount}");

  // Reuse object
  // 重用对象
  Bullet bullet2 = PooledObject.createInstance<Bullet>();
  bullet2.initialize();
  print("Reused bullet at (${bullet2.x}, ${bullet2.y}), active: ${bullet2.active}");
}
