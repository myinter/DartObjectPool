import 'dart:core';

/// Base class for all pooled objects.
/// 所有可回收对象的基类。
///
/// Using object pooling reduces the overhead of frequent object creation
/// and destruction by reusing existing objects.
/// 使用对象池可以避免频繁的对象创建和销毁，通过重用对象来降低开销。
///
/// Example: game entities, messages, temporary objects.
/// 例如：游戏中的子弹对象、即时消息对象、临时数据容器。
abstract class PooledObject {
  /// Static map of object pools for different types.
  /// 静态 Map，用于存储不同类型的对象池。
  static final Map<Type, ObjectPool> _pools = {};

  /// Creates an instance of type [T] from its associated pool.
  /// 从对象池中获取一个类型 [T] 的实例。
  /// Throws [StateError] if the pool for type [T] is not initialized.
  /// 如果类型 [T] 的对象池没有初始化，则抛出 [StateError]。
  static T createInstance<T extends PooledObject>() {
    final pool = _pools[T];
    if (pool == null) {
      throw StateError("ObjectPool for type $T has not been initialized. / 类型 $T 的对象池尚未初始化。");
    }
    return pool.acquire() as T;
  }

  /// (Optional) Single pool per subclass.
  /// （可选）每个子类可持有自己的单一对象池。
  static ObjectPool? _pool;

  /// The pool this object belongs to.
  /// 当前对象所归属的对象池。
  ObjectPool? currentPool;

  /// Initialize object before use. Subclasses must implement.
  /// 对象初始化逻辑，子类必须实现。
  void initialize();

  /// Release object before recycling. Subclasses must implement.
  /// 对象释放逻辑，子类必须实现。
  void release();

  /// Registers an object pool for type [T] with a factory method.
  /// 使用工厂方法为类型 [T] 初始化对象池。
  static void initializePool<T extends PooledObject>(T Function() createPoolObject) {
    _pools[T] = ObjectPool<T>(createPoolObject);
  }

  /// Releases this object back into its pool for reuse.
  /// 将当前对象回收到对象池中，以便重复利用。
  void releaseToPool() {
    if (currentPool != null) {
      release(); // execute release logic / 调用释放逻辑
      currentPool!.release(this);
    }
  }

  /// Subclass factory method (unimplemented here).
  /// 子类工厂方法（此处未实现，需要子类自定义）。
  static T _createInstance<T extends PooledObject>() {
    throw UnimplementedError('Please implement a factory for $T / 请为 $T 实现工厂方法');
  }
}

/// Generic object pool class.
/// 通用对象池类。
class ObjectPool<T extends PooledObject> {
  /// List of available recycled objects.
  /// 可用的已回收对象列表。
  final List<T> _availableObjects = [];

  /// Factory method to create new objects if pool is empty.
  /// 当池中无可用对象时，用于创建新对象的工厂方法。
  final T Function() creator;

  ObjectPool(this.creator);

  /// Acquire an object from the pool.
  /// 从对象池中获取对象。
  /// If pool is empty, a new object will be created.
  /// 如果池中无可用对象，则会创建新对象。
  T acquire() {
    if (_availableObjects.isNotEmpty) {
      print("_availableObjects ${_availableObjects.length}");
      return _availableObjects.removeLast();
    } else {
      T obj = creator();
      obj.currentPool = this;
      return obj;
    }
  }

  /// Release an object back to the pool.
  /// 将对象回收到对象池中。
  void release(T obj) {
    _availableObjects.add(obj);
  }

  /// Get the number of available (recycled) objects.
  /// 获取当前可用（已回收）对象的数量。
  int get availableCount => _availableObjects.length;
}
