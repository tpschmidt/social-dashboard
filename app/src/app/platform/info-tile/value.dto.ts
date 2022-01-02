import {DateTime} from "luxon";

export class ValueDto {
  value: number
  timestamp: DateTime

  constructor(value: number, timestamp: string) {
    this.value = value
    this.timestamp = DateTime.fromFormat(timestamp, 'yyyyLLdd-HHmmss')
  }

  static of(value: number, timestamp: string): ValueDto {
    return new ValueDto(value, timestamp)
  }
}
