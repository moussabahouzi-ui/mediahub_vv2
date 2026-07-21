// =============================================================================
// MediaHub v2 — Either<L, R> (Phase 0 stand-in)
// Authority: ADR-009 (typed failures + Either)
// =============================================================================
// Phase 0: minimal hand-rolled Either. Phase 1+ may migrate to `dartz` or
// `fpdart` per ADR-009 ("we standardise on dartz's Either for ecosystem
// reasons") — for Feature #1 the hand-rolled version is sufficient.
//
// IRON LAW (ADR-009): Failures cross the domain boundary as VALUES, never as
// thrown exceptions. Repository methods return Either<Failure, T>.

sealed class Either<L, R> {
  const Either();
}

class Left<L, R> extends Either<L, R> {
  const Left(this.value);
  final L value;
}

class Right<L, R> extends Either<L, R> {
  const Right(this.value);
  final R value;
}
