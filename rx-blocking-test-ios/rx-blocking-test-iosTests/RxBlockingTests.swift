import XCTest
import RxSwift
import RxBlocking
import RxTest

@testable import rx_blocking_test_ios


class RxBlockingTests: XCTestCase {

    var isVisible: Variable<Bool> = Variable<Bool>(false)
    var isHidden: Observable<Bool> = Observable<Bool>.create { observer in
        observer.onNext(false)
        observer.onNext(true)
        observer.onCompleted()
        return Disposables.create()
    }
    var onTapped: PublishSubject<Void> = PublishSubject<Void>()
    var disposeBag: DisposeBag = DisposeBag()

    func testVariableBoolCollector() {
        let collector = VariableBoolCollector().collect(from: isVisible)
        isVisible.value = false
        isVisible.value = false
        isVisible.value = true
        XCTAssertEqual(collector.toArray, [false, false, false, true])
    }

    func testObservableBoolCollector() {
        let collector = ObservableBoolCollector().collect(from: isHidden)
        XCTAssertEqual(collector.toArray, [false, true])
    }

    func testVoidCollector() {
        let collector = VoidCollector().collect(from: onTapped)
        onTapped.onNext(())
        onTapped.onNext(())
        onTapped.onNext(())
        XCTAssertEqual(collector.toArray.count, 3)
    }
}

class VoidCollector {
    var disposeBag: DisposeBag = DisposeBag()
    var toArray: [Void] = [Void]()

    func collect( from variable: PublishSubject<Void>) -> VoidCollector {
        variable.asObservable()
            .subscribe(onNext: { () in
                self.toArray.append(())
            }).addDisposableTo(disposeBag)
        return self
    }
}

class VariableBoolCollector {
    var disposeBag: DisposeBag = DisposeBag()
    var toArray: [Bool] = [Bool]()

    func collect( from variable: Variable<Bool>) -> VariableBoolCollector {
        variable.asObservable()
            .subscribe(onNext: { (isVisible) in
                self.toArray.append(isVisible)
            }).addDisposableTo(disposeBag)
        return self
    }
}

class ObservableBoolCollector {
    var disposeBag: DisposeBag = DisposeBag()
    var toArray: [Bool] = [Bool]()

    func collect( from observable: Observable<Bool>) -> ObservableBoolCollector {
        observable.asObservable()
            .subscribe(onNext: { (isVisible) in
                self.toArray.append(isVisible)
            }).addDisposableTo(disposeBag)
        return self
    }
}



