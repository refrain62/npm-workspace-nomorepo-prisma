import { PrismaClient } from "@prisma/client"

main()

async function main() {
  const prisma = new PrismaClient()
  const records = await prisma.record.findMany({})
  console.log(records)
}
