"""create chartPatternSignal

Revision ID: 3a4d57f834e6
Revises: 232c9d758365
Create Date: 2015-08-24 19:04:52.183000

"""

# revision identifiers, used by Alembic.
revision = '3a4d57f834e6'
down_revision = '232c9d758365'
branch_labels = None
depends_on = None

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.create_table(
        'chartPatternSignal',
        sa.Column('id', sa.Integer, primary_key=True),
        sa.Column('patternId', sa.Integer, nullable=False),
        sa.Column('stockCode', sa.String(5), nullable=False),
        sa.Column('signalTime', sa.TIMESTAMP, nullable=False),
        sa.Column('price', sa.Float, nullable=False),
        sa.Column('lineID', sa.String(100), nullable=False),
    )
    pass


def downgrade():
    op.drop_table('chartPatternSignal')
    pass
