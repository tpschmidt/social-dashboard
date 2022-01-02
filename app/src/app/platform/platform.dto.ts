import {DataDto} from "./data.dto";

export class PlatformDto {
  url: string | undefined
  name: string | undefined
  data: DataDto[] = []
}
