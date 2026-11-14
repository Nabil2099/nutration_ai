double progress(double consumed, double goal) =>
    !consumed.isFinite || !goal.isFinite || goal <= 0
    ? 0
    : (consumed / goal).clamp(0.0, 1.0);
