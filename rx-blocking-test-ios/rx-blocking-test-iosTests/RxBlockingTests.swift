import XCTest
import RxSwift
import RxBlocking
import RxTest

@testable import rx_blocking_test_ios


class RxEasyCollectorTests: XCTestCase {

    var isVisible: Variable<Bool> = Variable<Bool>(false)
    var isHidden: Observable<Bool> = Observable<Bool>.create { observer in
        observer.onNext(false)
        observer.onNext(true)
        observer.onCompleted()
        return Disposables.create()
    }
    var onTapped: PublishSubject<Void> = PublishSubject<Void>()
    var disposeBag: DisposeBag = DisposeBag()

    func testBoolCollector() {
        let collector = RxCollector<Bool>().collect(from: isVisible.asObservable())
        isVisible.value = false
        isVisible.value = false
        isVisible.value = true
        XCTAssertEqual(collector.toArray, [false, false, false, true])
    }

    func testObservableBoolCollector() {
        let collector = RxCollector<Bool>().collect(from: isHidden)
        XCTAssertEqual(collector.toArray, [false, true])
    }

    func testVoidCollector() {
        let collector = RxCollector<Void>().collect(from: onTapped.asObservable())
        onTapped.onNext(())
        onTapped.onNext(())
        onTapped.onNext(())
        XCTAssertEqual(collector.toArray.count, 3)
    }
}

class RxCollector<T> {
    var disposeBag: DisposeBag = DisposeBag()
    var toArray: [T] = [T]()

    func collect( from observable: Observable<T>) -> RxCollector {
        observable.asObservable()
            .subscribe(onNext: { (isVisible) in
                self.toArray.append(isVisible)
            }).addDisposableTo(disposeBag)
        return self
    }
}



